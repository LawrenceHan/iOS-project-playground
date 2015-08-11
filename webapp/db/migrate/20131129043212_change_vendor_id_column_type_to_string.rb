class ChangeVendorIdColumnTypeToString < ActiveRecord::Migration
  def change
    change_column(:hospitals, :vendor_id, :string)
    change_column(:physicians, :vendor_id, :string)
  end
end
