class CreateCalendarShares < ActiveRecord::Migration[8.1]
  def change
    create_table :calendar_shares do |t|
      t.references :calendar, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :calendar_shares, [ :calendar_id, :user_id ], unique: true
  end
end
