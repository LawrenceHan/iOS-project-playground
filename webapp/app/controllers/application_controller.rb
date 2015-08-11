class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_admin, :admin_signed_in?, :current_admin_id, :current_user, :user_signed_in?

  around_filter :set_current_user_id

  def set_current_user_id
    User.current_user_id = current_user.try(:id)
    yield
  ensure
    User.current_user_id = nil
  end

  def current_admin
    @current_admin ||= Admin.find_by_id(current_admin_id)
  end

  def admin_signed_in?
    current_admin_id.present?
  end

  def current_admin_id
    session[:admin_id].presence || cookies.signed[:admin_id].presence
  end

  # TODO: confirm the dashboard page
  def dashboard_path
    admin_panel_admins_path
  end

  def default_url_options(options={})
    locale = @no_locale ? nil : I18n.locale
    { :locale => locale }
  end

  ### devise methods, copied from devise gem
  def warden
    request.env['warden']
  end

  def user_signed_in?
    warden.authenticated?
  end

  def guest_signed_in?
    warden.authenticated?(:guest)
  end

  def current_guest
    @current_guest ||= warden.user(:guest)
  end

  def current_user
    @current_user ||= warden.user
  end

  def current_user_or_guest
    current_user || current_guest
  end

  def authenticate_user!
    warden.authenticate!(new_session_url: mobile_sign_in_path )
  end

  def authenticate_user_or_guest!
    user = warden.authenticate || warden.authenticate(scope: :guest)
    throw(:warden, new_session_url: mobile_sign_in_path) unless user

    user
  end

  def sign_in(user, opts={})
    warden.set_user(user, opts)
  end

  def sign_out(*scopes)
    if scopes and scopes.include?(:guest)
      @current_guest = nil
    else
      @current_user = nil
    end

    cookies.delete :remember_me_token # Remeber me is not added as
    warden.raw_session.inspect # Without this inspect here. The session does not clear.
    warden.logout(*scopes)
    warden.clear_strategies_cache!
  end
  ### end of devise methods

  protected
  def require_admin!
    if !admin_signed_in?
      flash.alert = 'You must login first to access!'
      redirect_to admin_panel_login_path
      return false
    end
  end

  def require_logout!
    if admin_signed_in?
      redirect_to dashboard_path
      return false
    end
  end
end
