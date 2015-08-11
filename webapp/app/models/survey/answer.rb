module Survey
  class Answer < ActiveRecord::Base
    self.table_name = 'survey_answers'

    belongs_to :question, class_name: 'Survey::Question'
    belongs_to :feedback, class_name: 'Survey::Feedback'
  end
end
