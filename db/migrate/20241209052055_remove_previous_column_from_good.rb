class RemovePreviousColumnFromGood < ActiveRecord::Migration[7.2]
  def change
    remove_column :goods , :user_id , :integer
  end
end
