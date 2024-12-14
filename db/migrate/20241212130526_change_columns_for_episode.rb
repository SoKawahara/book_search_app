class ChangeColumnsForEpisode < ActiveRecord::Migration[7.2]
  def change
    change_column :episodes , :reading_history , :string , null: false
  end
end
