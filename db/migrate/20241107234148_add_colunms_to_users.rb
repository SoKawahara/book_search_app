class AddColunmsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :profile_completed, :boolean , default: false
  end
end
