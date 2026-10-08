class CreateArchivals < ActiveRecord::Migration[8.1]
  def change
    create_table :archivals do |t|
      t.references :user, null: false, foreign_key: true
      t.references :note, null: false, foreign_key: true

      t.timestamps
    end

    add_index :archivals, [ :user_id, :note_id ], unique: true
  end
end
