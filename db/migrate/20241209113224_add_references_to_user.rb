class AddReferencesToUser < ActiveRecord::Migration[7.2]
  def change
    add_reference :goods, :user, foreign_key: true
  end
end
