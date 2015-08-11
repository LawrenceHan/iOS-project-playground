class CreateSurveyDefinitions < ActiveRecord::Migration
  def change
    create_table :survey_definitions do |t|
      t.json :definition
      t.string :s_type

      t.timestamps
    end
  end
end
