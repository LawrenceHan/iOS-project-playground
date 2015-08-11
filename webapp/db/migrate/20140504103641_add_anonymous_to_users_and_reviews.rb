class AddAnonymousToUsersAndReviews < ActiveRecord::Migration
  def change
    add_column 'reviews', 'is_anonymous', :boolean, null: false, default: false
    add_column 'profiles', 'anonymous_username', :string, limit: 50
    add_index 'profiles', 'anonymous_username'
  end
end
