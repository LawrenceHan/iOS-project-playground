class AddIsGuestToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_guest, :boolean, default: false
    change_column_null :users, :email, true
    change_column_default :users, :email, nil
  end
end
