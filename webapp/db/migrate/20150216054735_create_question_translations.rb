class CreateQuestionTranslations < ActiveRecord::Migration
  def up
    Question.create_translation_table!({
      :content => :string
    }, {
      :migrate_data => true
    })
  end

  def down
    Question.drop_translation_table!
  end
end
