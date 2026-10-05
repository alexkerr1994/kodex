class CalendarShare < ApplicationRecord
  belongs_to :calendar
  belongs_to :user

  validates :user_id, uniqueness: { scope: :calendar_id }
end
