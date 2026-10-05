class Tag < ApplicationRecord
  belongs_to :user
  has_many :note_tags, dependent: :destroy
  has_many :notes, through: :note_tags

  validates :name, presence: true, uniqueness: { scope: :user_id, case_sensitive: false }

  PALETTE = %w[#a06e57 #6b8e6b #6b7f9e #9e6b8e #b58a3c #4f8a8b #c25b56].freeze

  # Deterministic colour per name so a tag keeps its colour across sessions.
  def self.color_for(name)
    PALETTE[name.to_s.downcase.sum % PALETTE.length]
  end
end
