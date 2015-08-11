class AddReasonToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :reason, :string
  end
end
