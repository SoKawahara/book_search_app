class AddClomns3ToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :birthday, :string, default: "未設定"
    add_column :users, :oppucations, :string , default: "未設定"
    add_column :users, :gender, :string, default: "未設定"
  end
end
