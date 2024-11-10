class RemoveColunmFromUsers < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :genre, :string
    remove_column :users, :readability, :integer
    remove_column :users, :convenience, :integer
    remove_column :users, :recommendation, :integer
  end
end
