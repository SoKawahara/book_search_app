class CreateEpisodes < ActiveRecord::Migration[7.2]
  def change
    create_table :episodes do |t|
      t.datetime :reading_history , null: false
      t.string :title , null: false
      t.string :trigger 
      t.string :about_trigger , null: false
      t.string :about_changing , null: false
      t.string :changing
      t.datetime :episode_update_time
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
