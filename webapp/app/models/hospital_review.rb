class HospitalReview < Review
  belongs_to :hospital, foreign_key: 'reviewable_id'
  validates :medical_experience_id, uniqueness: true

  delegate :name, to: :hospital, allow_nil: true
  delegate :human_avg_waiting_time, to: :hospital, prefix: true
  validates :medical_experience_id, presence: true

  after_create :assign_hospital_to_medical_experience!
  after_save :update_hospital_avg_rating!, :update_hospital_avg_waiting_time!
  after_destroy :update_hospital_avg_rating!, :update_hospital_avg_waiting_time!, :reload_hospital_id_in_medical_experience

  def reviewable_name
    hospital.try(:name)
  end

  def reviewable_rating
    hospital.try(:avg_rating)
  end

  def self.questions
    Question.hospital_questions
  end

  private
  def update_hospital_avg_rating!
    return true if self.hospital.blank?
    self.hospital.update_avg_rating!
  end

  def update_hospital_avg_waiting_time!
    return true if self.hospital.blank?
    self.hospital.update_avg_waiting_time!
  end

  def assign_hospital_to_medical_experience!
    return true if self.medical_experience.hospital_id?
    self.medical_experience.update_columns(hospital_id: self.hospital.try(:id))
  end

  def reload_hospital_id_in_medical_experience
    medical_experience.reload_hospital_id if medical_experience
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
