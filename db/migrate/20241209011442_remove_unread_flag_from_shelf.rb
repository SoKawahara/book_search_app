class RemoveUnreadFlagFromShelf < ActiveRecord::Migration[7.2]
  def change
    remove_column :shelves , :read_flag , :integer 
  end
end
