class AddLimitToEpisode < ActiveRecord::Migration[7.2]
  def change
    change_column :episodes , :trigger , :string, limit: 1000
    change_column :episodes , :changing , :string , limit: 1000
  end
end
