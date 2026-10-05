class NetworkMembership < ApplicationRecord
  belongs_to :network
  belongs_to :user

  enum :role, { member: 0, admin: 1 }

  validates :user_id, uniqueness: { scope: :network_id }
end
