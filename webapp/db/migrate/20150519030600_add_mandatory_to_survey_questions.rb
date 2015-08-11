class AddMandatoryToSurveyQuestions < ActiveRecord::Migration
  def change
    add_column :survey_questions, :mandatory, :boolean, default: false, null: false
  end
end
