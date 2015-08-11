class RemoveSpecialityIdsFromPhysicians < ActiveRecord::Migration
  def change
    remove_index :physicians, :speciality_ids
    remove_columns :physicians, :speciality_ids
  end
end
