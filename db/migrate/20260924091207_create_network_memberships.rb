class CreateNetworkMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :network_memberships do |t|
      t.references :network, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :role, null: false, default: 0

      t.timestamps
    end

    add_index :network_memberships, [ :network_id, :user_id ], unique: true
  end
end
