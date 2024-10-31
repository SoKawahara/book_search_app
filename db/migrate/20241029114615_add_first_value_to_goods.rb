class AddFirstValueToGoods < ActiveRecord::Migration[7.2]
  def change
    change_column_default :goods, :evaluation_count, 0
    change_column_default :goods, :good_count  , 0
  end
end
