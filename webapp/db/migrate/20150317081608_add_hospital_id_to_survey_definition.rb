class AddHospitalIdToSurveyDefinition < ActiveRecord::Migration
  def change
    add_reference :survey_definitions, :hospital, index: true
  end
end
