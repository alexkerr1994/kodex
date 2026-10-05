class Calendar < ApplicationRecord
  belongs_to :user
  has_many :events, dependent: :destroy
  has_many :calendar_shares, dependent: :destroy
  has_many :shared_with_users, through: :calendar_shares, source: :user
  has_many :calendar_network_shares, dependent: :destroy
  has_many :shared_networks, through: :calendar_network_shares, source: :network

  validates :name, presence: true, uniqueness: { scope: :user_id, case_sensitive: false }

  PALETTE = %w[#a06e57 #6b8e6b #6b7f9e #9e6b8e #b58a3c #4f8a8b #c25b56].freeze

  def self.color_for(name)
    PALETTE[name.to_s.downcase.sum % PALETTE.length]
  end
end
