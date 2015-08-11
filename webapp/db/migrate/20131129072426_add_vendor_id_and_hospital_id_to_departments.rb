class AddVendorIdAndHospitalIdToDepartments < ActiveRecord::Migration
  def change
    add_column :departments, :vendor_id, :string
    add_reference :departments, :hospital, index: true
  end
end
