class AddDosageToMedications < ActiveRecord::Migration
  def change
    add_column :medications, :dosage, :string
  end
end
