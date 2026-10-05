class Folder < ApplicationRecord
  belongs_to :user
  has_many :note_filings, dependent: :destroy
  has_many :notes, through: :note_filings

  validates :name, presence: true, uniqueness: { scope: :user_id, case_sensitive: false }
end
