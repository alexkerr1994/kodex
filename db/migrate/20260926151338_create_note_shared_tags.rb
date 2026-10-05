class CreateNoteSharedTags < ActiveRecord::Migration[8.1]
  def change
    create_table :note_shared_tags do |t|
      t.references :note, null: false, foreign_key: true
      t.string :name, null: false
      t.string :color

      t.timestamps
    end

    add_index :note_shared_tags, [:note_id, :name], unique: true
  end
end
