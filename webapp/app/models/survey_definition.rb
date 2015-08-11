# FIXME: old result model
class SurveyDefinition < ActiveRecord::Base
  belongs_to :hospital
  has_many :survey_results
end
