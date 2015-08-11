module AuthorizeHelper
  include CommonHelper

  def warden
    env['warden']
  end

  def authenticate!
    warden.authenticate!
    User.current_user_id = current_user.try(:id)
  end

  def login
    warden.authenticate!
    User.current_user_id = current_user.try(:id)
    say_succeed current_user.profile || {}
  end

  def current_user
    warden.user
  end

  # the summany for the current user, return to app after user login
  def current_user_summary
    current_user.as_json(only: :email, methods: :username)
  end

  # Use Encrypted Cookie
  def _cookies
    ActionDispatch::Request.new(env).cookie_jar
  end

  def logout
    current_user.profile.update_attribute(:ios_device_token, nil) if current_user

    warden.logout
    warden.clear_strategies_cache!
    _cookies.delete(:remember_me_token)
    User.current_user_id = nil
    say_succeed
  end
end
