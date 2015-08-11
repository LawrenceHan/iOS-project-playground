class CreateSurveyTranslations < ActiveRecord::Migration
  def up
    Survey::Survey.create_translation_table!({
      :title => :string
    }, {
      :migrate_data => true
    })
  end

  def down
    Survey::Survey.drop_translation_table!
  end
end
