class NoteSharedTag < ApplicationRecord
  belongs_to :note

  validates :name, presence: true, uniqueness: { scope: :note_id, case_sensitive: false }
end
