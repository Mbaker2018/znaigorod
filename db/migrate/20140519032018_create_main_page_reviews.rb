class CreateMainPageReviews < ActiveRecord::Migration
  def create_main_page_review_records
    (1..4).each { |i| MainPageReview.create! :position => i }
  end

  def change
    create_table :main_page_reviews do |t|
      t.references :review
      t.integer :position
      t.datetime :expires_at

      t.timestamps
    end
    add_index :main_page_reviews, :review_id

    create_main_page_review_records
  end
end
