require 'file_size_validator'

class Profile < ActiveRecord::Base
  include ClearArray

  ANONYMOUS_USERNAME_CHARS = %w(0 1 2 3 4 5 6 7 8 9)

  mount_uploader :avatar, UserAvatarUploader
  # store_in_background :avatar
  can_clear_array :condition_ids

  belongs_to :user
  has_one :weibo_auth, through: :user
  has_one :tqq_auth, through: :user
  has_one :facebook_auth, through: :user
  has_one :twitter_auth, through: :user
  has_many :comments, through: :user
  has_many :reviews, through: :user
  has_many :medical_experiences, through: :user

  validates :avatar, file_size: { maximum: 0.5.megabytes.to_i }
  validates :user_id, :username, presence: true
  # TODO: hardcoded adult age and lifespan...
  validates :birthdate, inclusion: { in: (Date.today - 100.years)..(Date.today - 17.years), on: :update, allow_nil: true } # User must older than 18
  validates_numericality_of :height, greater_than_or_equal_to: 0.5, less_than_or_equal_to: 3, allow_nil: true, on: :update
  validates_numericality_of :weight, greater_than_or_equal_to: 1, less_than_or_equal_to: 650, allow_nil: true, on: :update

  before_save :calculate_completion
  before_save :set_locale

  COMPLETION_MAP = {
    username: 0.05,
    gender: 0.05,
    birthdate: 0.05,
    avatar: 0.15,
    linked_to_weibo: 0.1,
    linked_to_tqq: 0.1,
    condition_ids: 0.2,
    height: 0.05,
    weight: 0.05,
    occupation: 0.05,
    city: 0.05,
    education_level: 0.05,
    income_level: 0.05
  }
  MOBILE_INTERESTS = [
    I18n.t('step_three.mobile_interests0'),
    I18n.t('step_three.mobile_interests1'),
    I18n.t('step_three.mobile_interests2')
  ]

  # For API
  def thumb_avatar
    "#{ApplicationHelper.host}#{avatar.thumb.url}"
  end

  def small_avatar
    "#{ApplicationHelper.host}#{avatar.small.url}"
  end

  def age
    return nil if birthdate.blank?
    now = DateTime.now
    age = now.year - birthdate.year
    age -= 1 if(now.yday < birthdate.yday)

    age
  end

  def human_conditions
    return nil if self.condition_ids.blank?
    # FIXME: globalize doesn't well with pluck
    Condition.where('id IN (?)', self.condition_ids).all.map(&:name).join(' ')
  end

  def conditions
    Condition.where(id: self.condition_ids)
  end

  def condition_ids=(new_val)
    if new_val.present?
      self[:condition_ids] = new_val.reject(&:blank?).map(&:to_i)
    else
      super
    end
  end

  def health_condition_ids
    condition_ids
  end

  def health_conditions
    HealthCondition.where(id: health_condition_ids)
  end

  def human_interests
    return nil if self.interests.blank?
    self.interests.join(',')
  end

  def birthplace
    [self.city, self.country].delete_if(&:blank?).join(',')
  end

  def human_completion
    ActionController::Base.helpers.number_to_percentage(self.completion.to_f * 100, precision: 0)
  end

  def calculate_completion
    c = 0.0
    COMPLETION_MAP.each_pair do |attr, percentage|
      c += percentage if self.__send__("#{attr}").present?
    end
    self.completion = c
  end

  def set_locale
    self.locale = I18n.locale
  end

  def notifications
    comments.unread.count
  end

  def medical_experiences_count
    medical_experiences.count
  end

  def completed_reviews_count
    reviews.where(:completion => 1.0).count
  end

  def pending_reviews_count
    reviews.pending.count
  end

  def review_counts
    reviews.group(:type).select("type, count(*) as count").as_json(only:[:count, :type])
  end

  def linked_to_weibo
    weibo_auth.present?
  end

  def linked_to_tqq
    tqq_auth.present?
  end

  def linked_to_facebook
    facebook_auth.present?
  end

  def linked_to_twitter
    twitter_auth.present?
  end
  alias_method :linked_to_weibo?, :linked_to_weibo
  alias_method :linked_to_tqq?, :linked_to_tqq
  alias_method :linked_to_facebook?, :linked_to_facebook
  alias_method :linked_to_twitter?, :linked_to_twitter

  def as_json(*args)
    super(only:
          [:id, :user_id, :username, :completion, :height, :weight, :gender,
           :country, :region, :city, :pathway, :income_level, :birthdate,
           :occupation, :education_level, :network_visible, :interests],
           methods:
           [:medical_experiences_count, :completed_reviews_count, :linked_to_weibo,
            :linked_to_tqq, :human_conditions, :age, :thumb_avatar, :notifications,
            :review_counts, :pending_reviews_count, :conditions]).merge(:username => display_username)
  end

  def public_attributes
    {
      :id => self.id,
      :user_id => self.user_id,
      :gender => self.gender,
      :height => self.height,
      :weight => self.weight,
      :username => self.display_username,
      :thumb_avatar => self.thumb_avatar,
      :age => self.age,
      :country => self.country,
      :region => self.region,
      :city => self.city,
      :review_counts => self.review_counts,
      :medical_experiences_count => self.medical_experiences_count
    }
  end

  def display_username
    if user_id != User.current_user_id && attributes['username'] =~ /\A#{User::INIT_NAME_PREFIX}\d+\z/
      I18n.t('anonymous')
    else
      attributes['username']
    end
  end

  def has_interest?(interest)
    self[:interests].to_a.include?(interest)
  end

  def anonymous_username
    update(anonymous_username: self.class.generate_unique_anonymous_username) unless self[:anonymous_username]
    super
  end

  def self.generate_anonymous_username
    name = ""
    6.times { name << ANONYMOUS_USERNAME_CHARS.sample }

    User::INIT_NAME_PREFIX + name
  end

  def self.generate_unique_anonymous_username
    begin
      name = generate_anonymous_username
    end while where(anonymous_username: name).exists?

    name
  end
end

# == Schema Information
#
# Table name: profiles
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  username           :string(255)
#  avatar             :string(255)
#  gender             :string(255)
#  birthdate          :date
#  height             :float
#  weight             :float
#  pathway            :string(255)
#  occupation         :string(255)
#  country            :string(255)
#  city               :string(255)
#  network_visible    :boolean
#  income_level       :string(255)
#  condition_ids      :integer          default([]), is an Array
#  interests          :string(255)      default([]), is an Array
#  social_friends     :json
#  completion         :float            default(0.0)
#  created_at         :datetime
#  updated_at         :datetime
#  education_level    :string(255)
#  region             :string(255)
#  avatar_tmp         :string(255)
#  ios_device_token   :string(255)
#  anonymous_username :string(50)
#
