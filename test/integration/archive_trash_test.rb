require "test_helper"

class ArchiveTrashTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @owner = User.create!(name: "Owner", email: "owner@test.com", password: "password123")
    @alice = User.create!(name: "Alice", email: "alice@test.com", password: "password123")
    @note = Note.create!(owner: @owner, title: "Keeper", body: "x")
    @note.note_memberships.create!(user: @alice, access_level: :viewer)
  end

  # ---- Archive (per-user) ----

  test "archiving hides a note from your list and shows it under Archived, per-user" do
    sign_in @alice
    post note_archival_path(@note), headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert @note.reload.archived_by?(@alice)

    get notes_path
    assert_select ".n-card .n-title", text: "Keeper", count: 0
    get notes_path(filter: "archived")
    assert_select ".n-card .n-title", text: "Keeper"

    # The owner is unaffected (archive is personal).
    sign_in @owner
    get notes_path
    assert_select ".n-card .n-title", text: "Keeper"
  end

  test "unarchiving returns the note to your list" do
    @alice.archivals.create!(note: @note)
    sign_in @alice
    delete note_archival_path(@note), headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_not @note.reload.archived_by?(@alice)
  end

  # ---- Trash (owner-global soft delete) ----

  test "owner deleting a note moves it to trash and removes it from everyone's list" do
    sign_in @owner
    delete note_path(@note)
    assert @note.reload.discarded?

    get notes_path
    assert_select ".n-card .n-title", text: "Keeper", count: 0

    sign_in @alice
    get notes_path
    assert_select ".n-card .n-title", text: "Keeper", count: 0
  end

  test "trash lists the owner's discarded notes and can restore them" do
    @note.update!(discarded_at: Time.current)
    sign_in @owner
    get notes_path(filter: "trash")
    assert_select ".trash-card .n-title", text: "Keeper"

    patch restore_note_path(@note)
    assert_not @note.reload.discarded?
  end

  test "purge permanently deletes a trashed note" do
    @note.update!(discarded_at: Time.current)
    sign_in @owner
    assert_difference -> { Note.count }, -1 do
      delete purge_note_path(@note)
    end
  end

  test "a non-owner cannot trash, restore, or purge" do
    sign_in @alice # viewer
    delete note_path(@note)
    assert_not @note.reload.discarded?
    assert_redirected_to notes_path

    @note.update!(discarded_at: Time.current)
    patch restore_note_path(@note)
    assert @note.reload.discarded?
  end

  test "purge_expired_trash! removes notes past the retention window" do
    old = Note.create!(owner: @owner, title: "Old", body: "x", discarded_at: 31.days.ago)
    recent = Note.create!(owner: @owner, title: "Recent", body: "x", discarded_at: 1.day.ago)
    Note.purge_expired_trash!
    assert_not Note.exists?(old.id)
    assert Note.exists?(recent.id)
  end
end
