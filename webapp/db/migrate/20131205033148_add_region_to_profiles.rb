class AddRegionToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :region, :string
  end
end
