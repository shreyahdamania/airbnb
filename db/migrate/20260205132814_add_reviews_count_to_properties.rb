class AddReviewsCountToProperties < ActiveRecord::Migration[8.0]
  def change
    add_column :properties, :reviews_count, :integer
  end
end
