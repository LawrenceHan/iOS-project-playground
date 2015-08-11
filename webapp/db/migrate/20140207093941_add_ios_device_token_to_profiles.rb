class AddIosDeviceTokenToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :ios_device_token, :string
  end
end
