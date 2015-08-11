class AddCityToHospitals < ActiveRecord::Migration
  def change
    add_column :hospitals, :city, :string
  end
end
