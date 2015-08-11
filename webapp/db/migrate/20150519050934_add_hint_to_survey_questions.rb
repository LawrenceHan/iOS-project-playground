class AddHintToSurveyQuestions < ActiveRecord::Migration
  def up
    add_column :survey_questions, :hint, :string

    Survey::Question.add_translation_fields! hint: :string
  end

  def down
    remove_column :survey_question_translations, :hint

    remove_column :survey_questions, :hint
  end
end
