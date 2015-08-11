# Provide cookies for Warden
module Warden::Mixins::Common
  def request
    @request ||= ActionDispatch::Request.new(env)
  end

  def cookies
    request.cookie_jar
  end
end

# Warden configurations
Rails.application.config.middleware.use Warden::Manager do |config|
  config.default_strategies :remember_me, :password
  config.failure_app = UnauthorizedController
end

Warden::Manager.serialize_into_session do |user|
  user.id
end

#FIXME: should remove Admin after we merge User and Admin
Warden::Manager.serialize_from_session do |id|
  User.find_by(id: id) || Admin.find_by(id: id)
end

# remember_me strategy
Warden::Strategies.add(:remember_me) do
  def valid?
    cookies.signed[:remember_me_token].present?
  end

  def authenticate!
    if cookies.signed[:remember_me_token]
      if user = User.find_by(id: cookies.signed[:remember_me_token]) || Admin.find_by(id: cookies.signed[:remember_me_token])
        success! user
      else
        cookies.delete(:remember_me_token)
      end
    end
  end
end

# password strategy
Warden::Strategies.add(:password) do
  def valid?
    return false if request.get?
    user_data = params["user"] || params["admin"] || {}
    !(user_data["email"].blank? || user_data["password"].blank?) ||
    !(user_data["phone"].blank? || user_data["password"].blank?)
  end

  def authenticate!
    # A guest cannot login by email and password, because he/she simply doesn't have
    email = (params['user'] || params['admin'])['email']
    phone = (params['user'] || params['admin'])['phone']
    password = (params['user'] || params['admin'])['password']
    remember_me = (params['user'] || params['admin'])['remember_me']
    user = if params['user']
             email.present? ? User.where('is_guest != ?', true).find_by(email: email) :
               User.where('is_guest != ?', true).find_by(phone: phone)
           else
             email.present? ? Admin.find_by(email: email) : Admin.find_by(phone: phone)
           end
    if user && user.authenticate(password)
      # if user.confirmed?
        success! user
        # Remember me
        cookies.signed['remember_me_token'] = { value: user.id, expires: 1.month.from_now } if remember_me == '1'
      # else
      #   fail! I18n.t('api.session.not_confirm')
      # end
    else
      fail! I18n.t('api.session.login_failed')
    end
  end
end

# failure app for warden
class UnauthorizedController < ActionController::Metal
  include ActionController::Redirecting

  def self.call(env)
    @respond ||= action(:respond)
    @respond.call(env)
  end

  def respond
    if warden_options[:new_session_url]
      redirect_to warden_options[:new_session_url]
    else
      self.status = 401
      message = env['warden'].message || I18n.t('error.unauthorized')
      self.response_body = { error: message }.to_json
    end
  end

  def warden
    env['warden']
  end

  def warden_options
    env['warden.options']
  end
end
