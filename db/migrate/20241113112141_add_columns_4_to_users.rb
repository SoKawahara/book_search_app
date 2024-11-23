class AddColumns4ToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :episode, :text, default: "未設定"
  end
end
