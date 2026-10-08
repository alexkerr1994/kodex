class CreateNetworkInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :network_invitations do |t|
      t.references :network, null: false, foreign_key: true
      t.references :invited_user, null: false, foreign_key: { to_table: :users }
      t.references :invited_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :network_invitations, [ :network_id, :invited_user_id ], unique: true
  end
end
