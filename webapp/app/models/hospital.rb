require 'httparty'

class Hospital < ActiveRecord::Base
  translates :name, :official_name, :address, :description, fallbacks_for_empty_translations: true

  enum ownership: [:public_owned, :private_owned, :military_owned]

  include QuestionAvgRatings
  include AvgRatingReading
  include ReviewableExt
  include GeoFetcher
  include HospitalMerging
  include AggregatedSearchable

  H_CLASSES = %w(一级甲等 一级乙等 一级丙等 一级未评 二级甲等 二级乙等 二级丙等 二级未评 三级甲等 三级乙等 三级丙等 三级未评 未评定)

  reverse_geocoded_by :latitude, :longitude

  has_many :departments_hospitals, dependent: :destroy
  has_many :departments, through: :departments_hospitals

  has_many :physicians, dependent: :destroy
  has_many :specialities, -> { uniq }, through: :physicians
  has_many :medical_experiences, dependent: :destroy
  has_many :hospital_reviews, foreign_key: 'reviewable_id', dependent: :destroy

  has_many :published_hospital_reviews, -> { where(status: 'published') }, foreign_key: 'reviewable_id', dependent: :destroy, class_name: 'HospitalReview'
  has_many :published_physician_reviews, through: :medical_experiences
  has_many :published_medication_reviews, through: :medical_experiences
  has_many :published_answers, through: :published_hospital_reviews, source: :answers

  belongs_to :parent_hospital, class_name: 'Hospital', foreign_key: 'parent_id'
  has_many :sub_hospitals, class_name: 'Hospital', foreign_key: 'parent_id'

  has_many :aggregated_searches, as: :searchable_entity

  attr_accessor :distance

  scope :has_physicians, -> { where("physicians_count > 0") }
  scope :nearby, ->(lat, lng, scope) { where("distance_in_km(hospitals.latitude, hospitals.longitude, #{lat}, #{lng}) <= ?", scope).select("id, distance_in_km(hospitals.latitude, hospitals.longitude, #{lat}, #{lng}) AS distance").order('distance') }
  scope :within_area, ->(lat, lng, sw_lat, sw_lng, ne_lat, ne_lng) { where("hospitals.latitude > ? AND hospitals.latitude < ? AND hospitals.longitude > ? AND hospitals.longitude < ?", sw_lat, ne_lat, sw_lng, ne_lng).select("distance_in_km(hospitals.latitude, hospitals.longitude, #{lat}, #{lng}) AS distance").order('distance') }
  scope :order_by_distance, ->(lat, lng) { select("distance_in_km(hospitals.latitude, hospitals.longitude, #{lat}, #{lng}) AS distance").order('distance') }
  default_scope -> { preload(:translations) }

  validates_uniqueness_of :vendor_id, allow_nil: true

  before_create :generate_vendor_id

  def highly_reviews_departments
    departments.joins(:published_physician_reviews).includes(:physicians).group('departments.id').select("departments.id, departments.name, COUNT(reviews.*) as reviews_count").order('reviews_count DESC').limit(2).as_json(methods: :physicians_count)
  end

  def latitude
    read_attribute(:latitude).to_f
  end

  def longitude
    read_attribute(:longitude).to_f
  end

  def human_departments
    self.departments.map(&:name).join(',')
  end

  def human_avg_waiting_time
    Hospital.human_avg_waiting_time(self.avg_waiting_time)
  end

  def update_avg_waiting_time!
    return if self.published_hospital_reviews.count == 0
    self.update_columns(avg_waiting_time: self.published_answers.includes(:question).where("questions.question_type = ?", "waiting_time").references(:questions).sum(:waiting_time) / self.published_hospital_reviews.count)
  end

  def update_avg_rating!
    self.update_columns(avg_rating: self.published_hospital_reviews.average('avg_rating').to_f.round(2))
  end

  # Not sure why :reverse_geocoded_by doesn't work. So I have this
  def reverse_geocode
    coordinates = get_coordinates
    if coordinates
      update(latitude: coordinates[0], longitude: coordinates[1])
    else
      logger.warn "Failed to reverse geocode Hospital id=#{id}, address=#{address}"
    end
  end

  def get_coordinates
    Geocoder.coordinates address
  end

  def localized_h_class
    if self.private_owned?
      I18n.t('私立')
    else
      I18n.t h_class.presence, default: I18n.t('未评定')
    end
  rescue
    p $!
  end

  def as_json(options = {})
    super(options).merge("h_class" => localized_h_class)
  end

  def searchable_json
    attrs = [:id, :name, :address, :h_class, :latitude, :longitude]
    as_json(only: attrs, methods: [:class_name, :avg_rating, :reviews_count, :human_distance])
  end

  def reviews_count
    published_hospital_reviews.count
  end

  def self.reverse_geocode_all
    where(latitude: 0, longitude: 0).find_each do |hospital|
      hospital.reverse_geocode
    end
  end

  def self.human_avg_waiting_time(avg_waiting_time)
    return "#{I18n.t('word.unknown')}" if avg_waiting_time.blank?
    if avg_waiting_time.to_i < 60
      "#{avg_waiting_time}#{I18n.t('unit.minutes')}"
    else
      hours, minutes = avg_waiting_time.to_i.divmod(60)
      if minutes > 0
        "%d#{I18n.t('unit.hour')}%d#{I18n.t('unit.minutes')}" % [hours, minutes]
      else
        "#{hours}#{I18n.t('unit.hour')}"
      end
    end
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
# Table name: hospitals
#
#  id               :integer          not null, primary key
#  vendor_id        :string(255)
#  name             :string(255)
#  official_name    :string(255)
#  phone            :string(255)
#  address          :string(255)
#  post_code        :string(255)
#  h_class          :string(255)
#  avg_waiting_time :integer
#  avg_rating       :float            default(0.0)
#  created_at       :datetime
#  updated_at       :datetime
#  latitude         :decimal(, )      default(0.0)
#  longitude        :decimal(, )      default(0.0)
#  city             :string(255)
#  parent_id        :integer
#

