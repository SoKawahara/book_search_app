class CreateGoods < ActiveRecord::Migration[7.2]
  def change
    create_table :goods do |t|
      t.json :book_data
      t.integer :good_count
      t.integer :evaluation_count
      t.text :content
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
