class AddHospitalToMedicalExperiences < ActiveRecord::Migration
  def change
    add_reference :medical_experiences, :hospital, index: true
  end
end
