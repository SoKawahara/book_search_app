class AddIndexToColumns2ToLike < ActiveRecord::Migration[7.2]
  def change
    add_index :likes , [:user_id , :good_id] , unique: true , name: "index_likes_on_user_id_and_good_id"
  end
end
