module Survey
  class Feedback < ActiveRecord::Base
    self.table_name = 'survey_feedbacks'

    belongs_to :survey, class_name: 'Survey::Survey'
    has_many :answers, class_name: 'Survey::Answer', dependent: :destroy

    accepts_nested_attributes_for :answers
  end
end
