class AddEmailToHospitals < ActiveRecord::Migration
  def change
    add_column :hospitals, :email, :string
  end
end
