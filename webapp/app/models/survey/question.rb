module Survey
  class Question < ActiveRecord::Base
    self.table_name = 'survey_questions'
    translates :title, :default_value, :options, :hint, fallbacks_for_empty_translations: true

    belongs_to :survey, class_name: 'Survey::Survey'
    has_many :answer, class_name: 'Survey::Answer', dependent: :destroy

    scope :order_by_position, -> { order('position asc') }
    default_scope -> { preload(:translations) }
  end
end
