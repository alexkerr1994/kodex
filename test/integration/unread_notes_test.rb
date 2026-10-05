require "test_helper"

class UnreadNotesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @owner  = User.create!(name: "Owner", email: "owner@test.com", password: "password123")
    @editor = User.create!(name: "Editor", email: "editor@test.com", password: "password123")
    @note = Note.create!(owner: @owner, title: "Shared", body: "x", last_edited_by: @owner)
    @note.note_memberships.create!(user: @editor, access_level: :editor)
  end

  test "a note changed by someone else shows unread on your list" do
    # Owner has seen it, then the editor changes it.
    NoteView.create!(user: @owner, note: @note, last_viewed_at: 1.hour.ago)
    @note.update!(body: "edited by someone else", last_edited_by: @editor)

    sign_in @owner
    get notes_path
    assert_select ".n-card.unread .n-title", text: "Shared"
  end

  test "opening the note clears its unread state" do
    NoteView.create!(user: @owner, note: @note, last_viewed_at: 1.hour.ago)
    @note.update!(body: "edited by someone else", last_edited_by: @editor)

    sign_in @owner
    assert_difference -> { NoteView.where(user: @owner, note: @note).count }, 0 do
      get note_path(@note) # touches the existing view row
    end
    get notes_path
    assert_select ".n-card.unread", count: 0
  end

  test "your own edits never mark a note unread for you" do
    sign_in @editor
    patch note_path(@note),
          params: { note: { title: "Shared", body: "my own change" } },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
    get notes_path
    assert_select ".n-card.unread", count: 0
  end
end
