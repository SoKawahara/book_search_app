class AddIndexToGoods < ActiveRecord::Migration[7.2]
  def change
    add_index :goods , [:created_at]
  end
end
