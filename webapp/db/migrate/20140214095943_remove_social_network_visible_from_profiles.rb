class RemoveSocialNetworkVisibleFromProfiles < ActiveRecord::Migration
  def change
    remove_column :profiles, :social_network_visible
  end
end
