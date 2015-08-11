class RemoveReasonFromReviews < ActiveRecord::Migration
  def change
    remove_column :reviews, :reason
  end
end
