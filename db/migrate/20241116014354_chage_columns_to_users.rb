class ChageColumnsToUsers < ActiveRecord::Migration[7.2]
  def change
    change_column_default :users , :activated , true
  end
end
