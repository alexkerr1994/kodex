class Friendship < ApplicationRecord
  belongs_to :requester, class_name: "User"
  belongs_to :addressee, class_name: "User"

  enum :status, { pending: 0, accepted: 1 }

  validates :requester_id, uniqueness: { scope: :addressee_id }
  validate :not_self
  validate :no_reverse_duplicate, on: :create

  # The friendship row between two users, in either direction (or nil).
  def self.between(a, b)
    where(requester_id: a, addressee_id: b).or(where(requester_id: b, addressee_id: a)).first
  end

  private

  def not_self
    errors.add(:base, "You can't befriend yourself") if requester_id == addressee_id
  end

  def no_reverse_duplicate
    return if requester_id.blank? || addressee_id.blank?

    if Friendship.where(requester_id: addressee_id, addressee_id: requester_id).exists?
      errors.add(:base, "A friendship already exists between these users")
    end
  end
end
