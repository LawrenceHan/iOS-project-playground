require 'file_size_validator'

class Physician < ActiveRecord::Base
  translates :name, :description, fallbacks_for_empty_translations: true

  include QuestionAvgRatings
  include AvgRatingReading
  include ReviewableExt
  include AggregatedSearchable

  mount_uploader :avatar, FileUploader

  belongs_to :hospital, counter_cache: true
  belongs_to :department

  has_many :physicians_specialities, dependent: :destroy
  has_many :specialities, -> { uniq }, through: :physicians_specialities
  has_one :first_physicians_speciality, -> { where(priority: 1) }, class_name: 'PhysiciansSpeciality'
  has_one :second_physicians_speciality, -> { where(priority: 2) }, class_name: 'PhysiciansSpeciality'
  has_one :third_physicians_speciality, -> { where(priority: 3) }, class_name: 'PhysiciansSpeciality'
  has_one :first_speciality, through: :first_physicians_speciality, source: :speciality
  has_one :second_speciality, through: :second_physicians_speciality, source: :speciality
  has_one :third_speciality, through: :third_physicians_speciality, source: :speciality

  has_many :physician_reviews, foreign_key: 'reviewable_id', dependent: :destroy

  has_many :published_physician_reviews, -> { where(status: 'published') }, foreign_key: 'reviewable_id', dependent: :destroy, class_name: 'PhysicianReview'
  has_many :published_answers, through: :published_physician_reviews, source: :answers

  has_many :aggregated_searches, as: :searchable_entity

  default_scope -> { preload(:translations) }

  validates :avatar, file_size: { maximum: 0.5.megabytes.to_i }
  validates_uniqueness_of :vendor_id, allow_nil: true
  validates :gender, format: {
    with: /(male|female|unknown)/,
    message: 'only allows: male, female, unknown'
  }

  delegate :name, to: :first_speciality, prefix: true, allow_nil: true
  delegate :name, to: :second_speciality, prefix: true, allow_nil: true
  delegate :name, to: :third_speciality, prefix: true, allow_nil: true
  delegate :name, to: :department, prefix: true, allow_nil: true
  delegate :name, to: :hospital, prefix: true, allow_nil: true
  delegate :phone, to: :department, prefix: true, allow_nil: true
  delegate :h_class, to: :hospital, prefix: true, allow_nil: true

  after_initialize :init
  after_create :translate_to_pinyin, :generate_vendor_id

  def init
    self.gender ||= 'unknown' if self.new_record?
  end

  def translate_to_pinyin
    if attributes['name'] =~ /\p{Han}+/u && !translations.where("locale IN (?)", %w(en en-US)).exists? && I18n.locale.to_s == 'zh-CN'
      chinese_name = name
      I18n.locale = 'en'
      english_name = Pinyin.t(chinese_name).split(' ').map(&:capitalize).join(' ')
      self.name = english_name
      self.save
      I18n.locale = 'zh-CN'
      self.name = chinese_name
      self.save
    end
  end

  def first_speciality_id
    self.first_speciality.try(:id)
  end

  def first_speciality_id=(value)
    self.first_speciality = Speciality.find_by(id: value.to_i)
  end

  def second_speciality_id
    self.second_speciality.try(:id)
  end

  def second_speciality_id=(value)
    self.second_speciality = Speciality.find_by(id: value.to_i)
  end

  def third_speciality_id
    self.third_speciality.try(:id)
  end

  def third_speciality_id=(value)
    self.third_speciality = Speciality.find_by(id: value.to_i)
  end

  def age
    return I18n.t('word.unknown') if birthdate.blank?
    Time.now.year - birthdate.year
  end

  def thumb_avatar
    "#{ApplicationHelper.host}#{avatar.thumb.url}"
  end

  def has_doc
    doc.present?
  end

  def doc_with_hospital_name
    doc['hospital_name'] = hospital_name
    doc
  end

  def human_specialities
    specialities.map(&:name).join(',')
  end

  def update_avg_waiting_time_and_avg_price!
    return if self.published_physician_reviews.count == 0
    self.update_columns(avg_waiting_time: self.published_answers.joins(:question).where("questions.question_type = ?", "waiting_time").sum(:waiting_time) / self.published_physician_reviews.count, avg_price: self.published_answers.prices.average(:price))
  end

  def human_avg_price
    # TODO: hard-coded currency
    return I18n.t('word.unknown') if avg_price.to_i.zero?
    "#{avg_price}#{APP_CONFIG[:node] == 'india' ? I18n.t('unit.inr') : I18n.t('unit.rmb')}"
  end

  def human_avg_waiting_time
    Hospital.human_avg_waiting_time(self.avg_waiting_time)
  end

  def localized_gender
    I18n.t(gender.presence, default: I18n.t('unknown'))
  end

  def localized_position
    I18n.t(position.presence, default: I18n.t('其他'))
  end

  def as_json(options = {})
    super(options).merge("gender" => localized_gender, "position" => localized_position)
  end

  def searchable_json
    attrs = [:id, :hospital_id, :name, :gender, :position]
    as_json(only: attrs, methods: [:class_name, :avg_rating, :reviews_count, :age, :thumb_avatar, :human_distance, :department_name, :department_phone, :human_specialities, :hospital_name, :hospital_h_class] )
  end

protected

  def generate_vendor_id
    if vendor_id.blank?
      self.vendor_id = SecureRandom.uuid
    end
  end
end

# == Schema Information
#
# Table name: physicians
#
#  id               :integer          not null, primary key
#  vendor_id        :string(255)
#  name             :string(255)
#  position         :string(255)
#  avg_rating       :float            default(0.0)
#  created_at       :datetime
#  updated_at       :datetime
#  birthdate        :date
#  gender           :string(255)
#  department_id    :integer
#  hospital_id      :integer
#  avg_waiting_time :integer
#  avg_price        :integer          default(0)
#

