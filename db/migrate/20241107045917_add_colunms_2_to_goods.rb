class AddColunms2ToGoods < ActiveRecord::Migration[7.2]
  def change
    add_column :goods, :genre, :string
    add_column :goods, :readability, :string
    add_column :goods, :convenience, :string
    add_column :goods, :recommendation, :string
  end
end
