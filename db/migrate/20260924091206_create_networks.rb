class CreateNetworks < ActiveRecord::Migration[8.1]
  def change
    create_table :networks do |t|
      t.string :name

      t.timestamps
    end
  end
end
