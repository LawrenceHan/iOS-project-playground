class RemoveSurveysHospitalId < ActiveRecord::Migration
  def change
    remove_column :surveys, :hospital_id
  end
end
