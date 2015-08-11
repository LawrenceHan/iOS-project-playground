class ChangeDosageColumnsFroMedications < ActiveRecord::Migration
  def change
    remove_column :medications, :dosage
    add_column :medications, :dosage1, :string
    add_column :medications, :dosage2, :string
    add_column :medications, :dosage3, :string
  end
end
