class ChangeDefaultValueToGoods < ActiveRecord::Migration[7.2]
  def change
    change_column_default :goods, :good_users , -1 
  end
end
