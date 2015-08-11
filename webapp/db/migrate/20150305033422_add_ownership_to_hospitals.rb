class AddOwnershipToHospitals < ActiveRecord::Migration
  def change
    add_column :hospitals, :ownership, :integer
  end
end
