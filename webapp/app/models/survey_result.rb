# FIXME: old result model
class SurveyResult < ActiveRecord::Base
  belongs_to :survey_definition
end
