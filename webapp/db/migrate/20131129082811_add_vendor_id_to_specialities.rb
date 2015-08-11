class AddVendorIdToSpecialities < ActiveRecord::Migration
  def change
    add_column :specialities, :vendor_id, :integer
  end
end
