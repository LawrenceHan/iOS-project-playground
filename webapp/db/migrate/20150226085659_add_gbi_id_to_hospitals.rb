class AddGbiIdToHospitals < ActiveRecord::Migration
  def change
    add_column :hospitals, :gbi_id, :integer
  end
end
