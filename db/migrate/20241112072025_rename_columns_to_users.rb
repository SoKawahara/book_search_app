class RenameColumnsToUsers < ActiveRecord::Migration[7.2]
  def change
    rename_column :users, :oppucations, :occupations
  end
end
