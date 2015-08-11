class CreateSurveyResults < ActiveRecord::Migration
  def change
    create_table :survey_results do |t|
      t.references :survey_definition, index: true
      t.json :result

      t.timestamps
    end
  end
end
