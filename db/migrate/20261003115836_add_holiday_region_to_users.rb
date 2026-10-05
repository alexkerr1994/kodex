class AddHolidayRegionToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :holiday_region, :string
  end
end
