class CreateNoteViews < ActiveRecord::Migration[8.1]
  def change
    create_table :note_views do |t|
      t.references :user, null: false, foreign_key: true
      t.references :note, null: false, foreign_key: true
      t.datetime :last_viewed_at, null: false

      t.timestamps
    end
    add_index :note_views, %i[user_id note_id], unique: true
  end
end
