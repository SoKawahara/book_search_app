class AddColumnToGoods < ActiveRecord::Migration[7.2]
  def change
    add_column :goods, :post_name, :string
  end
end
