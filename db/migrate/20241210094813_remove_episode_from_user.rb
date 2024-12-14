class RemoveEpisodeFromUser < ActiveRecord::Migration[7.2]
  def change
    remove_column :users , :episode , :text
    remove_column :users , :episode_updated_time , :datetime
  end
end
