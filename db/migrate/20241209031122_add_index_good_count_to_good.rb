class AddIndexGoodCountToGood < ActiveRecord::Migration[7.2]
  def change
    add_index :goods , :created_at
    add_index :goods , :good_count
  end
end
