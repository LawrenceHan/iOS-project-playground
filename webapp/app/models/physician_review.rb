class PhysicianReview < Review
  belongs_to :physician, foreign_key: 'reviewable_id'
  has_one :hospital, through: :physician
  has_many :specialities, through: :physician

  delegate :name, to: :physician, allow_nil: true
  delegate :human_avg_waiting_time, to: :physician, prefix: true
  delegate :human_avg_price, to: :physician, prefix: true

  validates :medical_experience_id, presence: true

  after_create :assign_hospital_to_medical_experience!
  after_save :update_physician_avg_rating!, :update_physician_avg_waiting_time_and_avg_price!
  after_destroy :update_physician_avg_rating!, :update_physician_avg_waiting_time_and_avg_price!

  def reviewable_name
    physician.try(:name)
  end

  def reviewable_rating
    physician.try(:avg_rating)
  end

  def self.questions
    Question.physician_questions
  end

  private
  def update_physician_avg_rating!
    return true if self.physician.blank?
    self.physician.update_columns(avg_rating: self.physician.published_physician_reviews.average('avg_rating').to_f.round(2))
  end

  def update_physician_avg_waiting_time_and_avg_price!
    return true if self.physician.blank?
    self.physician.update_avg_waiting_time_and_avg_price!
  end

  def assign_hospital_to_medical_experience!
    return true if self.medical_experience.hospital_id?
    self.medical_experience.update_columns(hospital_id: self.hospital.try(:id))
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
