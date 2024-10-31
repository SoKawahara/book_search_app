class AddIndexToGoods2 < ActiveRecord::Migration[7.2]
  def change
    add_index :goods , [:user_id , :created_at]
  end
end
