class CreateShelves < ActiveRecord::Migration[7.2]
  def change
    create_table :shelves do |t|
      t.json :book_info
      t.integer :unread_flag, default: 1
      t.integer :read_flag, default: 0
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
