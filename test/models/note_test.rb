require "test_helper"

class NoteTest < ActiveSupport::TestCase
  setup do
    @owner    = User.create!(name: "Owner",    email: "owner@test.com",    password: "password123")
    @editor   = User.create!(name: "Editor",   email: "editor@test.com",   password: "password123")
    @viewer   = User.create!(name: "Viewer",   email: "viewer@test.com",   password: "password123")
    @stranger = User.create!(name: "Stranger", email: "stranger@test.com", password: "password123")
    @note = Note.create!(owner: @owner, title: "T", body: "b", last_edited_by: @owner)
    @note.note_memberships.create!(user: @editor, access_level: :editor)
    @note.note_memberships.create!(user: @viewer, access_level: :viewer)
  end

  test "requires a title" do
    note = Note.new(owner: @owner)
    assert_not note.valid?
    assert_includes note.errors[:title], "can't be blank"
  end

  test "owner can read and edit" do
    assert @note.readable_by?(@owner)
    assert @note.editable_by?(@owner)
  end

  test "editor can read and edit; viewer can read but not edit" do
    assert @note.readable_by?(@editor)
    assert @note.editable_by?(@editor)
    assert @note.readable_by?(@viewer)
    assert_not @note.editable_by?(@viewer)
  end

  test "a stranger can neither read nor edit" do
    assert_not @note.readable_by?(@stranger)
    assert_not @note.editable_by?(@stranger)
  end

  test "a network share grants read, and edit only at editor level" do
    net = Network.create!(name: "Team")
    net.network_memberships.create!(user: @stranger, role: :member)
    share = @note.note_network_shares.create!(network: net, access_level: :viewer)

    assert @note.reload.readable_by?(@stranger)
    assert_not @note.reload.editable_by?(@stranger)

    share.update!(access_level: :editor)
    assert @note.reload.editable_by?(@stranger)
  end

  test "membership_for finds the user's membership" do
    assert_equal "editor", @note.membership_for(@editor).access_level
    assert_nil @note.membership_for(@stranger)
  end

  test "favorited_by? and archived_by? are per-user" do
    @note.favorites.create!(user: @viewer)
    @note.archivals.create!(user: @viewer)
    assert @note.favorited_by?(@viewer)
    assert_not @note.favorited_by?(@editor)
    assert @note.archived_by?(@viewer)
    assert_not @note.archived_by?(@editor)
  end

  test "tags_for returns only that user's tags" do
    red  = @owner.tags.create!(name: "red",  color: "#f00")
    blue = @editor.tags.create!(name: "blue", color: "#00f")
    @note.note_tags.create!(tag: red)
    @note.note_tags.create!(tag: blue)
    assert_equal ["red"],  @note.tags_for(@owner).map(&:name)
    assert_equal ["blue"], @note.tags_for(@editor).map(&:name)
  end

  test "folder_for returns the user's filing" do
    folder = @owner.folders.create!(name: "Work")
    @note.note_filings.create!(user: @owner, folder: folder)
    assert_equal folder, @note.folder_for(@owner)
    assert_nil @note.folder_for(@editor)
  end

  test "kept/discarded scopes and discarded?" do
    assert_includes Note.kept, @note
    assert_not_includes Note.discarded, @note

    @note.update!(discarded_at: Time.current)
    assert @note.discarded?
    assert_includes Note.discarded, @note
    assert_not_includes Note.kept, @note
  end

  test "purge_expired_trash! removes only notes past the retention window" do
    old    = Note.create!(owner: @owner, title: "old",    discarded_at: (Note::TRASH_RETENTION + 1.day).ago)
    recent = Note.create!(owner: @owner, title: "recent", discarded_at: 1.day.ago)

    assert_difference -> { Note.count }, -1 do
      Note.purge_expired_trash!
    end
    assert_not Note.exists?(old.id)
    assert Note.exists?(recent.id)
  end

  test "unread_for? flags edits by others until viewed" do
    NoteView.create!(user: @viewer, note: @note, last_viewed_at: 1.hour.ago)
    @note.update!(body: "changed", last_edited_by: @owner)

    assert @note.unread_for?(@viewer)      # someone else changed it
    assert_not @note.unread_for?(@owner)   # your own edit never counts

    NoteView.touch_for(@viewer, @note)
    assert_not @note.reload.unread_for?(@viewer)
  end
end
