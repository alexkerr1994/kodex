class NoteView < ApplicationRecord
  belongs_to :user
  belongs_to :note

  # Record (or refresh) when a user last looked at a note.
  def self.touch_for(user, note)
    view = find_or_initialize_by(user_id: user.id, note_id: note.id)
    view.update(last_viewed_at: Time.current)
  end
end
