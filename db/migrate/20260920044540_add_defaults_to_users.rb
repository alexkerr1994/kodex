class AddDefaultsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :default_view, :string, null: false, default: "list"
    add_column :users, :start_collapsed, :boolean, null: false, default: false
  end
end
