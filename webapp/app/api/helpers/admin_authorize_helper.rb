module AdminAuthorizeHelper
  include CommonHelper

  def warden
    env['warden']
  end

  def authenticate!
    warden.authenticate!
  end

  def login
    warden.authenticate!
    say_succeed
  end

  def current_user
    warden.user
  end

  # Use Encrypted Cookie
  def _cookies
    ActionDispatch::Request.new(env).cookie_jar
  end

  def logout
    warden.logout
    warden.clear_strategies_cache!
    _cookies.delete(:remember_me_token)
    say_succeed
  end
end
