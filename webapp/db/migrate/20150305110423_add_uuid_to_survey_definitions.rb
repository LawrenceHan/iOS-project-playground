class AddUuidToSurveyDefinitions < ActiveRecord::Migration
  def change
    add_column :survey_definitions, :uuid, :uuid, default: 'uuid_generate_v4()'
  end
end
