class AddLastEditedByToNotes < ActiveRecord::Migration[8.1]
  def change
    add_reference :notes, :last_edited_by, null: true, foreign_key: { to_table: :users }
  end
end
