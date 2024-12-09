class AddColumnToShelfs < ActiveRecord::Migration[7.2]
  def change
    add_column :shelves , :created_post , :integer , default: 0 
  end
end
