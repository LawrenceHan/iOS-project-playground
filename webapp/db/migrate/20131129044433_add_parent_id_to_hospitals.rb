class AddParentIdToHospitals < ActiveRecord::Migration
  def change
    add_column :hospitals, :parent_id, :integer
  end
end
