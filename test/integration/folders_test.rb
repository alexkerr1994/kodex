require "test_helper"

class FoldersTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(name: "Sam", email: "sam@test.com", password: "password123")
    @other = User.create!(name: "Pat", email: "pat@test.com", password: "password123")
    @note = Note.create!(owner: @user, title: "A note", body: "x")
  end

  test "filing a note into a new folder creates the folder and files it" do
    sign_in @user
    assert_difference -> { Folder.count }, 1 do
      patch note_filing_path(@note), params: { new_folder: "Projects" },
            headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end
    folder = @user.folders.find_by(name: "Projects")
    assert_equal folder, @note.reload.folder_for(@user)
  end

  test "a note has a single folder per user (re-filing moves it)" do
    a = @user.folders.create!(name: "A")
    b = @user.folders.create!(name: "B")
    sign_in @user
    patch note_filing_path(@note), params: { folder_id: a.id }
    assert_equal a, @note.reload.folder_for(@user)
    patch note_filing_path(@note), params: { folder_id: b.id }
    assert_equal b, @note.reload.folder_for(@user)
    assert_equal 1, @user.note_filings.where(note: @note).count
  end

  test "clearing the folder unfiles the note" do
    a = @user.folders.create!(name: "A")
    @user.note_filings.create!(note: @note, folder: a)
    sign_in @user
    patch note_filing_path(@note), params: { folder_id: "" }
    assert_nil @note.reload.folder_for(@user)
  end

  test "folders are per-user" do
    a = @user.folders.create!(name: "A")
    @user.note_filings.create!(note: @note, folder: a)
    assert_equal a, @note.folder_for(@user)
    assert_nil @note.folder_for(@other) # the other user has their own (empty) filing
  end

  test "filtering by a folder shows only its notes" do
    a = @user.folders.create!(name: "A")
    @user.note_filings.create!(note: @note, folder: a)
    Note.create!(owner: @user, title: "Elsewhere", body: "y")
    sign_in @user
    get notes_path(folder: a.id)
    assert_select ".n-card .n-title", text: "A note"
    assert_select ".n-card .n-title", text: "Elsewhere", count: 0
    assert_select ".sidebar .nav-item.active .label", text: "A"
  end

  test "renaming and deleting folders from settings" do
    a = @user.folders.create!(name: "A")
    @user.note_filings.create!(note: @note, folder: a)
    sign_in @user

    patch folder_path(a), params: { folder: { name: "Archive-ish" } },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_equal "Archive-ish", a.reload.name

    assert_difference -> { Folder.count }, -1 do
      delete folder_path(a), headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end
    # Deleting the folder unfiles the note but keeps the note.
    assert Note.exists?(@note.id)
    assert_nil @note.reload.folder_for(@user)
  end

  test "cannot file into another user's folder" do
    theirs = @other.folders.create!(name: "Theirs")
    sign_in @user
    patch note_filing_path(@note), params: { folder_id: theirs.id }
    assert_nil @note.reload.folder_for(@user)
  end
end
