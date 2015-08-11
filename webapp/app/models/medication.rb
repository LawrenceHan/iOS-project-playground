class Medication < ActiveRecord::Base
  translates :name, fallbacks_for_empty_translations: true

  include QuestionAvgRatings
  include AvgRatingReading
  include ReviewableExt
  include AggregatedSearchable

  has_many :medication_reviews, foreign_key: 'reviewable_id', dependent: :destroy

  has_many :published_medication_reviews, -> { where(status: 'published') }, foreign_key: 'reviewable_id', dependent: :destroy, class_name: 'MedicationReview'
  has_many :companies_medications, dependent: :destroy
  has_many :_companies, through: :companies_medications, source: :company # companies already used for API

  has_one  :companies_medication, -> { where.not(begin_at: nil).order(:begin_at) }
  has_one  :first_company, through: :companies_medication, source: :company

  has_one :cardinal_health

  belongs_to :master, class_name: 'Medication', foreign_key: 'master_id'
  has_many :local, class_name: 'Medication', foreign_key: 'master_id'

  scope :masters, -> { where(master_id: nil) }
  scope :locals, -> { where.not(master_id: nil) }

  validates_uniqueness_of :vendor_id, allow_nil: true

  accepts_nested_attributes_for :first_company

  def dosage
    [self.dosage1, self.dosage2, self.dosage3].delete_if(&:blank?).join(', ')
  end

  def human_companies
    companies.join(',')
  end

  def companies
    self._companies.select([:cn_name, :en_name]).map(&:name)
  end

  def company
    self.first_company.try(:name)
  end

  def first_company_id
    self.first_company.try(:id)
  end

  def first_company_id=(company_id)
    self.first_company = Company.find_by(id: company_id.to_i)
  end

  def searchable_json
    as_json(only: [:id, :name, :code],
            methods: [:class_name, :avg_rating, :reviews_count, :companies, :company, :dosage, :question_avg_ratings],
            include: {cardinal_health: {only: [:official_name,
                                               :common_name,
                                               :rx_otc,
                                               :company_name,
                                               :member_price,
                                               :sale_price,
                                               :indications,
                                               :adverse_reactions,
                                               :link] } })
  end

end

# == Schema Information
#
# Table name: medications
#
#  id            :integer          not null, primary key
#  vendor_id     :integer
#  name          :string(255)
#  code          :string(255)
#  avg_rating    :float            default(0.0)
#  created_at    :datetime
#  updated_at    :datetime
#  old_companies :string(255)      default([]), is an Array
#  master_id     :integer
#  dosage1       :string(255)
#  dosage2       :string(255)
#  dosage3       :string(255)
#  ibn_id        :integer
#  ibn_name      :string(255)
#  ibn_code      :string(255)
#  eph_id        :integer
#  eph_name      :string(255)
#  otc           :integer
#
