class RemoveIndexFromGoods < ActiveRecord::Migration[7.2]
  def change
    remove_index :goods, name: 'index_goods_on_created_at' # インデックスの名前を指定
    remove_index :goods, name: "index_goods_on_user_id"
  end
end
