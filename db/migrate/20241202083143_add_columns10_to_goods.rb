class AddColumns10ToGoods < ActiveRecord::Migration[7.2]
  def change
    add_column :goods, :shelf_id, :integer
  end
end
