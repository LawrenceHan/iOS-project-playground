class MedicalExperience < ActiveRecord::Base
  include AvgRatingReading
  include CompletionReading
  include ClearArray

  attr_accessor :is_anonymous
  can_clear_array :symptom_ids
  can_clear_array :condition_ids

  belongs_to :user
  belongs_to :referral_code
  has_one :profile, through: :user
  has_many :reviews, dependent: :destroy
  has_one  :hospital_review, dependent: :destroy
  has_many :physician_reviews, dependent: :destroy, after_remove: :reload_hospital_id do
    def hospital_ids
      joins(:physician).select('physicians.hospital_id').pluck('hospital_id')
    end
  end

  has_many :medication_reviews, dependent: :destroy

  has_many :published_reviews, -> { where(status: 'published') }, class_name: 'Review', dependent: :destroy
  has_one :published_hospital_review, -> { where(status: 'published') }, class_name: 'HospitalReview'
  has_many :published_physician_reviews, -> { where(status: 'published') }, class_name: 'PhysicianReview'
  has_many :published_medication_reviews, -> { where(status: 'published') }, class_name: 'MedicationReview'

  belongs_to :hospital
  has_many  :physicians, through: :physician_reviews
  has_many  :medications, through: :medication_reviews

  delegate :email, to: :user, prefix: true, allow_nil: true
  delegate :code, to: :referral_code, prefix: true, allow_nil: true

  accepts_nested_attributes_for :hospital_review, :physician_reviews, :medication_reviews, :reviews

  after_initialize { self.network_visible = user.authentications.any? if new_record? and user  }
  after_save :update_is_anonymous_for_reviews

  validates :user_id, presence: true

  def is_anonymous=(is_anonymous)
    @is_anonymous = ActiveRecord::ConnectionAdapters::Column.value_to_boolean(is_anonymous)
  end

  # Set referral_code_id by params[:medical_experience][:code]
  def referral_code=(value)
    self.referral_code_id = ReferralCode.get_id_by_code(value)
  end

  def human_symptoms
    return nil if self.symptom_ids.blank?
    # FIXME: globalize doesn't well with pluck
    Symptom.where(id: self.symptom_ids).all.map(&:name).join(' ')
  end

  def human_conditions
    return nil if self.condition_ids.blank?
    # FIXME: globalize doesn't well with pluck
    Condition.where(id: self.condition_ids).all.map(&:name).join(' ')
  end

  def conditions
    return [] if self.condition_ids.blank?
    Condition.where(id: self.condition_ids).select(:id, :name)
  end

  def symptoms
    return [] if self.symptom_ids.blank?
    Symptom.where(id: self.symptom_ids).select(:id, :name)
  end


  def health_condition_ids
    ret = []
    ret.concat(condition_ids) if condition_ids.present?
    ret.concat(symptom_ids) if symptom_ids.present?

    ret
  end


  # get all hospitals' ids associated with either hospital_review or physician_reviews
  def all_hospital_ids
    ids = physician_reviews.hospital_ids
    ids << hospital_review.reviewable_id if hospital_review

    ids
  end

  def condition_ids=(new_val)
    if new_val.present?
      self[:condition_ids] = new_val.reject(&:blank?).map(&:to_i)
    else
      super
    end
  end

  def symptom_ids=(new_val)
    if new_val.present?
      self[:symptom_ids] = new_val.reject(&:blank?).map(&:to_i)
    else
      super
    end
  end

  def health_conditions
    HealthCondition.where(id: health_condition_ids)
  end

  def human_completion
    ActionController::Base.helpers.number_to_percentage(self.completion.to_f * 100, precision: 0)
  end

  def api_data
    as_json(only: [:id, :completion, :avg_rating, :network_visible, :hospital_id, :created_at], methods: [:review_data])
  end

  def review_data
    reviews =
      if new_record?
        [hospital_review] + physician_reviews + medication_reviews
      else
        [published_hospital_review] + published_physician_reviews + published_medication_reviews
      end

    reviews.compact.map do |p|
      p.as_json(only: [:completion, :type], methods: :reviewable_name)
    end
  end

  # This method is used for calculate iOS local medication_experience completion and avg_rating
  def calculate_completion_and_avg_rating
    the_reviews = ([hospital_review] + physician_reviews + medication_reviews).compact
    if the_reviews.blank?
      self.completion = 0
      self.avg_rating = 0
    else
      the_reviews.map(&:calculate_completion_and_avg_rating)
      self.completion = (the_reviews.sum(&:completion).to_f / the_reviews.size)
      self.avg_rating = (the_reviews.sum(&:avg_rating).to_f / the_reviews.size).to_f.round(2)
    end
  end

  # ?: Why need calculate like this way?
  def update_completion_and_avg_rating!
    me_avg_rating = self.published_reviews.pluck('AVG("reviews"."avg_rating") AS me_avg_rating').first

    # Hospital review completion
    completions = [self.published_hospital_review.try(:completion).to_f]

    # Average of the physican reviews completions
    if self.published_physician_reviews.count == 0
      completions << 0
    else
      physician_completions = self.published_physician_reviews.map(&:completion)
      completions << physician_completions.inject{ |sum, el| sum + el }.to_f / physician_completions.size
    end

    # Average of the medication reviews completions
    if self.published_medication_reviews.count == 0
      completions << 0
    else
      medical_completions = self.published_medication_reviews.map(&:completion)
      completions << medical_completions.inject{ |sum, el| sum + el }.to_f / medical_completions.size
    end

    # The medical experience completion is the average of the 3 reviewable items completions
    me_completion = completions.inject{ |sum, el| sum + el }.to_f / completions.size

    self.update_columns(completion: me_completion, avg_rating: me_avg_rating)
  end

  def reload_hospital_id
    if hospital_id
      if (!hospital_review and physician_reviews.empty?) or
        !all_hospital_ids.include?(hospital_id)
        update hospital_id: nil
      end
    end
  end

  def update_is_anonymous_for_reviews
    unless @is_anonymous.nil?
      reviews.update_all(is_anonymous: @is_anonymous)
      @is_anonymous = nil
    end
  end

end

# == Schema Information
#
# Table name: medical_experiences
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  referral_code_id :integer
#  symptom_ids      :integer          is an Array
#  condition_ids    :integer          is an Array
#  network_visible  :boolean          default(TRUE)
#  behalf           :string(255)
#  completion       :float            default(0.0)
#  avg_rating       :float            default(0.0)
#  created_at       :datetime
#  updated_at       :datetime
#  hospital_id      :integer
#
