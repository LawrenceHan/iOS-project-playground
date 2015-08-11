class CreateSurveyAnswers < ActiveRecord::Migration
  def change
    create_table :survey_answers do |t|
      t.references :question, index: true
      t.references :feedback, index: true
      t.string :value
      t.string :other_value

      t.timestamps
    end
  end
end
