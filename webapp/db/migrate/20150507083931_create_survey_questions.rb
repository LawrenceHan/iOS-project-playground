class CreateSurveyQuestions < ActiveRecord::Migration
  def change
    create_table :survey_questions do |t|
      t.references :survey, index: true
      t.string :title
      t.string :type
      t.text :default_value
      t.text :options
      t.integer :position
      t.string :category

      t.timestamps
    end
  end
end
