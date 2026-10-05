require "test_helper"

class NoteViewTest < ActiveSupport::TestCase
  setup do
    @owner = User.create!(name: "Owner", email: "o@test.com", password: "password123")
    @other = User.create!(name: "Other", email: "ot@test.com", password: "password123")
    @note = Note.create!(owner: @owner, title: "T", body: "x", last_edited_by: @owner)
    @note.note_memberships.create!(user: @other, access_level: :editor)
  end

  test "own edits are never unread" do
    @note.update!(body: "y", last_edited_by: @owner)
    assert_not @note.unread_for?(@owner)
  end

  test "an edit by another user is unread until viewed" do
    NoteView.create!(user: @other, note: @note, last_viewed_at: 1.hour.ago)
    @note.update!(body: "y", last_edited_by: @owner)
    assert @note.unread_for?(@other)
  end

  test "touch_for records a fresh view and clears unread" do
    @note.update!(body: "y", last_edited_by: @owner)
    NoteView.touch_for(@other, @note)
    assert_not @note.reload.unread_for?(@other)
  end

  test "touch_for is idempotent per user+note" do
    NoteView.touch_for(@other, @note)
    assert_difference -> { NoteView.count }, 0 do
      NoteView.touch_for(@other, @note)
    end
  end
end
