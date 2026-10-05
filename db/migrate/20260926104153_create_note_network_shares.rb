class CreateNoteNetworkShares < ActiveRecord::Migration[8.1]
  def change
    create_table :note_network_shares do |t|
      t.references :note, null: false, foreign_key: true
      t.references :network, null: false, foreign_key: true
      t.integer :access_level, null: false, default: 0

      t.timestamps
    end

    add_index :note_network_shares, [:note_id, :network_id], unique: true
  end
end
