class ChangeBehalfToStringForMedicalExperiences < ActiveRecord::Migration
  def change
    change_column :medical_experiences, :behalf, :string
  end
end
