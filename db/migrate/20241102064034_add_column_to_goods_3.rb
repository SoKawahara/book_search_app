class AddColumnToGoods3 < ActiveRecord::Migration[7.2]
  def change
    add_column :goods, :good_users, :text
  end
end
