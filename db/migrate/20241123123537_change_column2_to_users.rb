class ChangeColumn2ToUsers < ActiveRecord::Migration[7.2]
  def change
    change_column_default :users, :activated, false
  end
end
