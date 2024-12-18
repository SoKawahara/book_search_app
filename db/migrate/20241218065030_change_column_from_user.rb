class ChangeColumnFromUser < ActiveRecord::Migration[7.2]
  def change
    change_column_default :users , :activated , from: false , to: true
  end
end
