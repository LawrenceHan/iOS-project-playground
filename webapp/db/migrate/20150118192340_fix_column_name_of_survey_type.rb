class FixColumnNameOfSurveyType < ActiveRecord::Migration
  def change
    rename_column :survey_definitions, :s_type, :survey_type
  end
end
