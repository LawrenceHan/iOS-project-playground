class AddLatitudeAndLongitudeToHospitals < ActiveRecord::Migration
  def change
    add_column :hospitals, :latitude, :decimal, precision: 15, scale: 8, default: 0.0
    add_column :hospitals, :longitude, :decimal, precision: 15, scale: 8, default: 0.0
  end
end
