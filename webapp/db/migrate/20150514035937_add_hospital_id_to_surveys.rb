class AddHospitalIdToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :hospital_id, :integer
  end
end
