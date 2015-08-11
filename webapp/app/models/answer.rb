class Answer < ActiveRecord::Base
  belongs_to :review
  belongs_to :hospital_review, foreign_key: 'review_id'
  belongs_to :physician_review, foreign_key: 'review_id'
  belongs_to :medication_review, foreign_key: 'review_id'
  has_one :hospital, through: :hospital_review
  has_one :physician, through: :physician_review
  belongs_to :question

  validates :question_id, presence: true
  validates :rating, rating: true
  validates_numericality_of :waiting_time, only_integer: true, allow_nil: true, greater_than_or_equal_to: 0

  validates_each :rating, :waiting_time do |record, attr, value|
    record.errors.add attr, 'rating and waiting_time can not both be empty' if record.rating.blank? && record.waiting_time.blank?
  end

  scope :prices, -> { joins(:question).where('questions.question_type = ?', 'price').where('answers.price IS NOT NULL').where('answers.price > 0') }

  delegate :content, to: :question, prefix: true
  delegate :question_type, to: :question, prefix: false

  def human_waiting_time
    self.class.humanize_waiting_time(self.waiting_time)
  end

  def self.humanize_waiting_time(waiting_time)
    return nil if waiting_time.nil?
    return "0#{I18n.t('unit.minute')}" if waiting_time.blank?
    waiting_time = waiting_time.to_i
    if waiting_time < 60
      "#{waiting_time}#{I18n.t('unit.minutes')}"
    else
      hours, minutes = waiting_time.divmod(60)
      if minutes > 0
        "%d#{I18n.t('unit.hour')}%d#{I18n.t('unit.minutes')}" % [hours, minutes]
      else
        "#{hours}#{I18n.t('unit.hour')}"
      end
    end
  end
end

# == Schema Information
#
# Table name: answers
#
#  id           :integer          not null, primary key
#  review_id    :integer
#  question_id  :integer
#  waiting_time :integer
#  rating       :integer          default(0)
#  created_at   :datetime
#  updated_at   :datetime
#  price        :integer          default(0)
#

