class CreateNoteFilings < ActiveRecord::Migration[8.1]
  def change
    create_table :note_filings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :note, null: false, foreign_key: true
      t.references :folder, null: false, foreign_key: true

      t.timestamps
    end

    # One filing per user per note (a note has a single folder home per user).
    add_index :note_filings, [:user_id, :note_id], unique: true
  end
end
