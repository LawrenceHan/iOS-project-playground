class AddAvatarToPhysicians < ActiveRecord::Migration
  def change
    add_column :physicians, :avatar, :string
  end
end
