class AddColumnsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :genre, :string
    add_column :users, :readability, :integer
    add_column :users, :convenience, :integer
    add_column :users, :recommendation, :integer
  end
end
