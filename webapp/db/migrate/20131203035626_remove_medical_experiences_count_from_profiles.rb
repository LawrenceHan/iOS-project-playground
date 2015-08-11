class RemoveMedicalExperiencesCountFromProfiles < ActiveRecord::Migration
  def change
    remove_column :profiles, :medical_experiences_count
  end
end
