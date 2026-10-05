class NetworkInvitation < ApplicationRecord
  belongs_to :network
  belongs_to :invited_user, class_name: "User"
  belongs_to :invited_by, class_name: "User"

  validates :invited_user_id, uniqueness: { scope: :network_id, message: "has already been invited" }
end
