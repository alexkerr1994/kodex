class CreateCalendarNetworkShares < ActiveRecord::Migration[8.1]
  def change
    create_table :calendar_network_shares do |t|
      t.references :calendar, null: false, foreign_key: true
      t.references :network, null: false, foreign_key: true

      t.timestamps
    end
    add_index :calendar_network_shares, [:calendar_id, :network_id], unique: true
  end
end
