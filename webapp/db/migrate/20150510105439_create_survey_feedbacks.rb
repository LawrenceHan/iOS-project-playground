class CreateSurveyFeedbacks < ActiveRecord::Migration
  def change
    create_table :survey_feedbacks do |t|
      t.references :survey, index: true
      t.boolean :display_medical_feedback
      t.boolean :receive_information

      t.timestamps
    end
  end
end
