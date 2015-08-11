class ChangeSurveyAnswersValue < ActiveRecord::Migration
  def change
    change_column :survey_answers, :value, :text
  end
end
