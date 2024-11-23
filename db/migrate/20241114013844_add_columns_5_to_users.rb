class AddColumns5ToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :episode_updated_time, :datetime ,default: Time.now
  end
end
