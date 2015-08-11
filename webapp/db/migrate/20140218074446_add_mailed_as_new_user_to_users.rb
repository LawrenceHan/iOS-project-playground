class AddMailedAsNewUserToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mailed_as_new_user, :boolean, default: false
  end
end
