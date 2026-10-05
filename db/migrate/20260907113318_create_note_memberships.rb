class CreateNoteMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :note_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :note, null: false, foreign_key: true
      t.integer :access_level, null: false, default: 0

      t.timestamps
    end

    add_index :note_memberships, [:user_id, :note_id], unique: true
  end
end
