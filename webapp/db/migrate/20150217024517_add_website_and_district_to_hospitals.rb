class AddWebsiteAndDistrictToHospitals < ActiveRecord::Migration
  def change
    add_column :hospitals, :website, :string
    add_column :hospitals, :district, :string
  end
end
