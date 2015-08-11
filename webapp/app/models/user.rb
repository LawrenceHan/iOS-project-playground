class User < ActiveRecord::Base
  acts_as_messageable

  # TODO: hardcoded india
  if APP_CONFIG[:node] == 'india'
    INIT_NAME_PREFIX = 'TCV'
  else
    INIT_NAME_PREFIX = '康语'
  end
  include UserExt::Confirmable
  include UserExt::Recoverable
  include UserExt::Socialable
  include UserExt::SocialFriendsFetcher
  include UserExt::SMS
  include UserExt::CurrentUser

  attr_accessor :skip_confirmation

  has_secure_password validations: false

  has_one :profile, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :feedback, dependent: :destroy
  has_many :writed_comments, class_name: 'Comment', foreign_key: 'writer_id'
  has_many :medical_experiences, dependent: :destroy
  has_many :hospital_reviews, through: :medical_experiences
  has_many :physician_reviews, through: :medical_experiences
  has_many :medication_reviews, through: :medical_experiences
  has_many :reviews, through: :medical_experiences
  has_many :published_reviews, through: :medical_experiences
  has_many :helpfuls, dependent: :nullify
  has_many :invitations, foreign_key: 'owner_email', primary_key: 'email'
  has_many :invite_requests, dependent: :destroy

  scope :new_users_for_mailing, -> { where.not(mailed_as_new_user: true) }
  scope :already_thanked_users, -> { where('created_at < ?', Time.new(2014, 1, 7)) }

  # Extensions for :has_secure_password

  with_options(if: ->(u) { !u.is_guest && u.password.present? }) do |klass|
    klass.validates :password, confirmation: true, length: { minimum: 8 }, on: :update
  end

  with_options(if: ->(u) { !u.is_guest }) do |klass|
    klass.validates_presence_of :password, presence: true, length: { minimum: 8 }, on: :create
    klass.validates_presence_of     :password_digest
    klass.validates :email, uniqueness: true, email: true, allow_blank: true
    # TODO: hardcoded india
    klass.validates_format_of :phone, allow_blank: true, with: APP_CONFIG[:node] == 'india' ? /\A\d{10}\z/ : /\A\d{11}\z/
    klass.validates_uniqueness_of :phone, on: :create
  end

  validates :username, uniqueness: true, allow_blank: true

  def username
    attributes['username'] || profile.try(:username)
  end

  %w(age gender height weight occupation birthplace education_level income_level human_conditions human_interests).each do |attr|
    class_eval <<-RUBY, __FILE__, __LINE__ + 1
      delegate :#{attr}, to: :profile, allow_nil: true
    RUBY
  end

  %w(weibo tqq facebook twitter).each do |attr|
    class_eval <<-RUBY, __FILE__, __LINE__ + 1
      delegate :linked_to_#{attr}?, to: :profile, allow_nil: true
    RUBY
  end

  # before_create { raise "Password digest missing on new record" if password_digest.blank? }
  after_create :initialize_profile
  after_create :set_default_locale

  def init_profile_name
    return attributes['username'] if attributes['username']

    id_prefix = self.id > 1000 ? '' : "0" * (4 - self.id.to_s.size)
    suffix = "#{id_prefix}#{self.id}"

    if is_guest
      "Guest#{suffix}"
    else
      "#{INIT_NAME_PREFIX}#{suffix}"
    end
  end

  def self.mail_to_new_users
    new_users_for_mailing.each(&:send_email_to_new_user!)
  end

  def self.mail_to_already_thanked_users
    already_thanked_users.each(&:send_email_as_already_thanked_user!)
  end

  def self.new_guest(attrs={}, &block)
    new({is_guest: true}.merge(attrs), &block)
  end

  def self.create_guest(attrs={}, &block)
    create({is_guest: true}.merge(attrs), &block)
  end

  def send_email_to_new_user!
    return if self.email.blank?
    default_locale = $redis.get default_locale_key
    UserMailer.to_new_user(self.email, default_locale).deliver
    self.update_columns(mailed_as_new_user: true)
  rescue => e
    self.update_columns(mailed_as_new_user: false)
    raise e
  end

  def send_email_as_already_thanked_user!
    return if self.email.blank?
    UserMailer.to_already_thanked_user(self.email).deliver
    self.update_columns(mailed_as_new_user: true)
  rescue => e
    self.update_columns(mailed_as_new_user: false)
    raise e
  end

  def send_email_as_survey_user
    UserMailer.to_survey_user(self.email).deliver
  end

  private
  def initialize_profile
    create_profile(username: init_profile_name)
  end

  def set_default_locale
    $redis.set default_locale_key, I18n.locale
  end

  def default_locale_key
    "users/#{id}/default_locale"
  end

end

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  phone                  :string(255)
#  email                  :string(255)
#  password_digest        :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  mailed_as_new_user     :boolean          default(FALSE)
#  is_guest               :boolean          default(FALSE)
#
