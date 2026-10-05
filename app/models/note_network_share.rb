class NoteNetworkShare < ApplicationRecord
  belongs_to :note
  belongs_to :network

  enum :access_level, { viewer: 0, editor: 1 }

  validates :network_id, uniqueness: { scope: :note_id }
end
