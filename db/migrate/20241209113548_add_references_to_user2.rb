class AddReferencesToUser2 < ActiveRecord::Migration[7.2]
  def change
    change_column_null :goods , :user_id , false
  end
end
