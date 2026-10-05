class NoteFiling < ApplicationRecord
  belongs_to :user
  belongs_to :note
  belongs_to :folder

  validates :note_id, uniqueness: { scope: :user_id }
  validate :folder_belongs_to_user

  private

  def folder_belongs_to_user
    errors.add(:folder, "must be one of your folders") if folder && folder.user_id != user_id
  end
end
