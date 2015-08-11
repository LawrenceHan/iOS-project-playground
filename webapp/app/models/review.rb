class Review < ActiveRecord::Base
  include AvgRatingReading
  include CompletionReading
  include ReviewExt
  include BlacklistChecking
  include AggregatedSearchable

  STATUS = %w(pending rejected published)
  VALID_STATUS = 'published'
  attr_accessor :dosage_count, :dosage_unit, :duration_count, :duration_unit, :current_user, :current_user_id

  belongs_to :medical_experience
  has_one :user, through: :medical_experience
  has_one :profile, through: :user
  has_many :answers, dependent: :destroy
  has_many :questions, through: :answers
  has_many :helpfuls, dependent: :destroy
  has_many :reports, as: :reportable, dependent: :destroy

  delegate :email, :phone, to: :user, prefix: true
  delegate :human_symptoms, to: :medical_experience, allow_nil: true
  delegate :human_conditions, to: :medical_experience, allow_nil: true

  scope :published, -> { where(status: 'published') }
  scope :pending, -> { where(status: 'pending') }
  scope :without_author, -> { joins('LEFT OUTER JOIN medical_experiences ON reviews.medical_experience_id = medical_experiences.id' +
                                    ' LEFT OUTER JOIN users ON medical_experiences.user_id = users.id').where('users.id is null') }

  validates :status, inclusion: { in: STATUS }

  accepts_nested_attributes_for :answers, reject_if: proc { |attrs|
    attrs['question_id'].blank? or
      (attrs['rating'].blank? and attrs['waiting_time'].blank? and attrs['price'].blank?)
  }

  after_save :calculate_completion_and_avg_rating_for_medical_experience
  after_destroy :calculate_completion_and_avg_rating_for_medical_experience
  before_validation :set_dosage_and_duration
  before_save :calculate_completion_and_avg_rating
  after_create :send_cardinal_health_coupon

  def reviewable_type
    self.class.model_name.human
  end

  def reviewable_name
    self.class.model_name.human
  end

  def notifiable
    false
  end

  def reviewable_questions
    Question.all
  end

  def human_type
    reviewable_type
  end

  def human_health_conditions
    [human_conditions, human_symptoms].compact.join(' ')
  end

  def user_id
    is_anonymous ? APP_CONFIG[:anonymous_profile_id] : user.id
  end

  def current_user_id
    @current_user_id || self[:current_user_id]
  end

  def from_social_network_of_user_id(target_user_id)
    profile.social_friends.values.flatten.include?(target_user_id)
  rescue
    false
  end

  def from_social_network
    from_social_network_of_user_id(current_user_id)
  end

  def waiting_time_answer(force_reload=false)
    @waiting_time_answer = nil unless force_reload
    @waiting_time_answer ||= answers.where.not(waiting_time: nil).first
  end

  def human_waiting_time
    waiting_time_answer ? Hospital.human_avg_waiting_time(waiting_time_answer.waiting_time) : nil
  end

  def price_answer(force_reload=false)
    @price_answer = nil unless force_reload
    @price_answer ||= answers.where.not(price: nil).where.not(price: 0).first
  end

  def price
    price_answer ? price_answer.price : nil
  end

  def promoted
    promoted_by(current_user_id)
  end

  def promoted_by(a_user_id)
    from_social_network_of_user_id(a_user_id) && medical_experience.network_visible
  end

  def question_avg_ratings
    group = {}
    # answers.includes(:question).each do |answer|
    answers.each do |answer|
      answer_value = case answer.question.question_type
      when 'waiting_time' then Question::WAITING_TIME_OPTIONS.find{|x| x.last == answer.waiting_time }.try(:first)
      when 'rating'       then answer.rating
      when 'price'        then answer.price
      end

      group[answer.question.content] = answer_value
    end
    group
  end

  def already_marked_as_helpful
    if current_user.nil?
      false
    else
      self.helpfuls.where(:user_id => self.current_user.id).count > 0
    end
  end

  # This method is used for calculate iOS local medication_experience completion and avg_rating
  def calculate_completion_and_avg_rating
    calculate_completion
    calculate_avg_rating
  end

  def send_cardinal_health_coupon
    if I18n.locale == 'zh-CN'
      Admin.first.send_message(user, I18n.t('cardinal_health_message_content'), I18n.t('cardinal_health_message_subject'))
      coupon.update_attributes(created_by: self, user: user, used: true)
    end
  end

  def searchable_json
    as_json(methods: [:class_name, :reviewable_name, :notifiable, :username, :thumb_avatar])
  end

  private

  def set_dosage_and_duration
    self.dosage = "#{self.dosage_count} #{self.dosage_unit}" if self.dosage_count.present? && self.dosage_unit.present?
    self.duration = "#{self.duration_count} #{self.duration_unit}" if self.duration_count.present? && self.duration_unit.present?
  end

  def calculate_completion_and_avg_rating_for_medical_experience
    self.medical_experience.try(:update_completion_and_avg_rating!)
  end

  def calculate_completion
    self.completion = 1.0
  end

  def calculate_avg_rating
    if (rating_answers = answers.select{|x| x.question.question_type == 'rating'}).present?
      self[:avg_rating] = (rating_answers.sum(&:rating).to_f / rating_answers.size).to_f.round(2)
      self.status = VALID_STATUS if self.avg_rating >= 2
    else
      self.avg_rating = 0
    end
  end

  def brothers
    self.medical_experience.reviews
  end

end

# == Schema Information
#
# Table name: reviews
#
#  id                    :integer          not null, primary key
#  medical_experience_id :integer
#  reviewable_id         :integer
#  type                  :string(255)
#  helpfuls_count        :integer          default(0)
#  dosage                :string(255)
#  intake_frequency      :string(255)
#  duration              :string(255)
#  adverse_effects       :string(255)
#  completion            :float            default(0.0)
#  avg_rating            :float            default(0.0)
#  note                  :text
#  status                :string(255)      default("pending")
#  created_at            :datetime
#  updated_at            :datetime
#  is_anonymous          :boolean          default(FALSE), not null
#
