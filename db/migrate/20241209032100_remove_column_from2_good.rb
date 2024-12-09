class RemoveColumnFrom2Good < ActiveRecord::Migration[7.2]
  def change
    remove_column :goods , :shelf_id , :integer
  end
end
