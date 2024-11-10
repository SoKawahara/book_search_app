class AddColunmToUser < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :reading_history, :string , default: "0"
    add_column :users, :favorite_genre, :string , default: "未設定"
    add_column :users, :recommendation_books, :json , default: { top_1: "未設定" , top_2: "未設定" , top_3: "未設定" }
  end
end
