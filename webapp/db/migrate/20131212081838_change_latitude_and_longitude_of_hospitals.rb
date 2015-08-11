class ChangeLatitudeAndLongitudeOfHospitals < ActiveRecord::Migration
  def change
    change_column(:hospitals, :latitude, :decimal, default: 0.0)
    change_column(:hospitals, :longitude, :decimal, default: 0.0)
  end
end
