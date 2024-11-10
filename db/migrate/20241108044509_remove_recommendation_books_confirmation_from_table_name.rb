class RemoveRecommendationBooksConfirmationFromTableName < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :recommendation_books_confirmation, :json
  end
end
