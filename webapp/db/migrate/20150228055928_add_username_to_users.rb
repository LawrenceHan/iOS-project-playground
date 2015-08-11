class AddUsernameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :username, :string
    Profile.find_each do |profile|
      user = profile.user
      user.username = profile.username
      user.save
    end
  end
end
