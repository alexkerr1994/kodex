class NoteMembership < ApplicationRecord
  belongs_to :user
  belongs_to :note

  enum :access_level, { viewer: 0, editor: 1 }

  validates :user_id, uniqueness: { scope: :note_id }
  # The owner controls the note directly and should never also be a member.
  validate :user_is_not_owner

  private

  def user_is_not_owner
    errors.add(:user, "is already the owner of this note") if note && note.owner_id == user_id
  end
end
