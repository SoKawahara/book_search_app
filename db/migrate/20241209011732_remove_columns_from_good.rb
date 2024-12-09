class RemoveColumnsFromGood < ActiveRecord::Migration[7.2]
  def change
    remove_column :goods , :evaluation_count , :integer
    remove_column :goods , :good_users , :text
  end
end
