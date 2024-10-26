class RemoveIndexFromUsers < ActiveRecord::Migration[7.2]
  def change
    remove_index :users, :email
  end
end
