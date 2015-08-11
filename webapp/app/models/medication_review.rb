class MedicationReview < Review
  belongs_to :medication, foreign_key: 'reviewable_id'
  has_one :hospital, through: :medical_experience

  delegate :name, to: :medication, allow_nil: true

  after_save :calculate_medication_avg_rating
  after_create :send_mailboxer_message
  after_destroy :calculate_medication_avg_rating

  def reviewable_name
    medication.try(:name)
  end

  def notifiable
    medication.cardinal_health.present?
  end

  def reviewable_rating
    medication.avg_rating
  end

  def self.questions
    Question.medication_questions
  end

  def send_mailboxer_message
    if medication.cardinal_health
      Admin.first.send_message(user, I18n.t('api.cardinal_review_message_body'), I18n.t('api.cardinal_review_message_subject'))
    end
  end

  private
  def calculate_medication_avg_rating
    medication_avg_rating = self.medication.published_medication_reviews.average('avg_rating').to_f.round(2)
    self.medication.update_columns(avg_rating: medication_avg_rating)
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
