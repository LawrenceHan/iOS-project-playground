class Question < ActiveRecord::Base
  translates :content, fallbacks_for_empty_translations: true

  CATEGORIES = %w(hospital physician medication)
  DEFAULT_CATEGORY = CATEGORIES.first
  # TODO: hardcoded strings for waiting time?
  WAITING_TIME_OPTIONS = [["无需等待", 0], ["5分钟", 5], ["10分钟", 10], ["15分钟", 15],
             ["30分钟", 30], ["45分钟", 45], ["1小时", 60], ["1小时15分钟", 75],
             ["1小时30分钟", 90], ["1小时45分钟", 105], ["2小时", 120], ["2小时30分钟", 150],
             ["3小时", 180], ["3小时30分钟", 210], ["4小时或更多", 240]]

  has_many :answers, dependent: :destroy
  # has_many :hospital_reviews, through: :answers
  # has_many :physician_reviews, through: :answers
  # has_many :medication_review, through: :answers
  # has_many :hospitals, through: :hospital_reviews
  # has_many :physicians, through: :physician_reviews
  # has_many :medications, through: :medication_reviews

  validates :content, :category, presence: true
  validates :category, inclusion: { in: CATEGORIES }
  validates_uniqueness_of :content, scope: :category

  scope :with_category, ->(category) { where(category: category) }
  scope :ratings, -> { where(question_type: 'rating') }
  scope :waiting_times, -> { where(question_type: 'waiting_time') }
  scope :prices, -> { where(question_type: 'price') }

  scope :hospital_questions, -> { where(category: 'hospital') }
  scope :physician_questions, -> { where(category: 'physician') }
  scope :medication_questions, -> { where(category: 'medication') }

  def human_category
    I18n.t("category.#{self.category}")
  end

  def as_json(*args)
    super(only: [:id, :category, :content, :question_type, :options])
  end
end

# == Schema Information
#
# Table name: questions
#
#  id            :integer          not null, primary key
#  category      :string(255)
#  content       :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  question_type :string(255)
#  options       :json
#

