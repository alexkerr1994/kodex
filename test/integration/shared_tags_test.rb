require "test_helper"

class SharedTagsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @owner  = User.create!(name: "Owner", email: "owner@test.com", password: "password123")
    @editor = User.create!(name: "Editor", email: "editor@test.com", password: "password123")
    @viewer = User.create!(name: "Viewer", email: "viewer@test.com", password: "password123")
    @note = Note.create!(owner: @owner, title: "T", body: "x")
    @note.note_memberships.create!(user: @editor, access_level: :editor)
    @note.note_memberships.create!(user: @viewer, access_level: :viewer)
  end

  test "owner can add a shared tag and it's visible to everyone" do
    sign_in @owner
    assert_difference -> { NoteSharedTag.count }, 1 do
      post note_shared_tags_path(@note), params: { name: "Urgent" },
           headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end
    tag = @note.note_shared_tags.find_by(name: "Urgent")
    assert tag.color.present?

    # A viewer sees it (read-only) on the note.
    sign_in @viewer
    get note_path(@note)
    assert_select "#note_shared_tags_#{@note.id} .tag-pill", text: /Urgent/
  end

  test "an editor can add and remove shared tags" do
    sign_in @editor
    post note_shared_tags_path(@note), params: { name: "Review" }, headers: { "Accept" => "text/vnd.turbo-stream.html" }
    tag = @note.note_shared_tags.find_by(name: "Review")
    assert tag

    assert_difference -> { NoteSharedTag.count }, -1 do
      delete note_shared_tag_path(@note, tag), headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end
  end

  test "a viewer cannot add or remove shared tags" do
    tag = @note.note_shared_tags.create!(name: "Locked", color: "#111111")
    sign_in @viewer
    assert_no_difference -> { NoteSharedTag.count } do
      post note_shared_tags_path(@note), params: { name: "Nope" }
    end
    assert_redirected_to notes_path

    delete note_shared_tag_path(@note, tag)
    assert NoteSharedTag.exists?(tag.id)
  end

  test "shared tags are per-note (not per-user) and duplicates are ignored" do
    sign_in @owner
    post note_shared_tags_path(@note), params: { name: "Urgent" }
    post note_shared_tags_path(@note), params: { name: "urgent" } # case-insensitive dup
    assert_equal 1, @note.note_shared_tags.count
  end

  test "creating a shared tag with a chosen colour uses it" do
    sign_in @owner
    post note_shared_tags_path(@note), params: { name: "Urgent", color: "#123456" },
         headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_equal "#123456", @note.note_shared_tags.find_by(name: "Urgent").color
  end

  test "the shared-tag combo suggests shared tags from your other notes" do
    other = Note.create!(owner: @owner, title: "Other", body: "x")
    other.note_shared_tags.create!(name: "Roadmap", color: "#111111")
    sign_in @owner
    get note_path(@note)
    assert_select "#note_shared_tags_#{@note.id} .tag-combo-option[data-name=?]", "Roadmap"
  end

  test "the viewer's read-only pane has no add form" do
    @note.note_shared_tags.create!(name: "Urgent", color: "#111111")
    sign_in @viewer
    get note_path(@note)
    assert_select "#note_shared_tags_#{@note.id} input[name=name]", count: 0
  end
end
