class ChangeColumnFromEpisode < ActiveRecord::Migration[7.2]
  def change
    add_column :episodes , :episode_complated , :integer , default: 0
  end
end
