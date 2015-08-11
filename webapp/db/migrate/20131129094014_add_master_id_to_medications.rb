class AddMasterIdToMedications < ActiveRecord::Migration
  def change
    add_column :medications, :master_id, :integer
    add_index :medications, :master_id
  end
end
