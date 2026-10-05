class Network < ApplicationRecord
  has_many :network_memberships, dependent: :destroy
  has_many :members, through: :network_memberships, source: :user
  has_many :network_invitations, dependent: :destroy

  validates :name, presence: true

  def member?(user)
    network_memberships.any? { |m| m.user_id == user.id }
  end

  def admin?(user)
    network_memberships.any? { |m| m.user_id == user.id && m.admin? }
  end

  def membership_for(user)
    network_memberships.find { |m| m.user_id == user.id }
  end

  # Guard so a network is never left without an admin.
  def other_admins?(except_membership)
    network_memberships.any? { |m| m.admin? && m.id != except_membership.id }
  end
end
