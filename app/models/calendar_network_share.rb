class CalendarNetworkShare < ApplicationRecord
  belongs_to :calendar
  belongs_to :network

  validates :network_id, uniqueness: { scope: :calendar_id }
end
