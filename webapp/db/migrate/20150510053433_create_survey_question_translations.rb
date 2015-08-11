class CreateSurveyQuestionTranslations < ActiveRecord::Migration
  def up
    Survey::Question.create_translation_table!({
      :title => :string,
      :default_value => :text,
      :options => :text
    }, {
      :migrate_date => true
    })
  end

  def down
    Survey::Question.drop_translation_table!
  end
end
