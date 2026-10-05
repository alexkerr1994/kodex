class AddPreferencesToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :theme, :string, null: false, default: "quill"
    add_column :users, :time_zone, :string
  end
end
