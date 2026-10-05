class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.references :calendar, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.boolean :all_day, null: false, default: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at
      t.integer :recurrence, null: false, default: 0
      t.date :recurrence_until

      t.timestamps
    end
    add_index :events, :starts_at
  end
end
