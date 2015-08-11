class Mobile::RegistrationsController < Mobile::BaseController
  skip_before_filter :verify_authenticity_token, only: [:request_validation_code]
  before_filter :authenticate_user!, if: :step_actions?
  self.css_namespace = 'sessions-controller'

  def new
    @user = User.new
  end

  def request_validation_code
    if !APP_CONFIG[:sms][:test_mode]
      sms_token = User.generate_sms_token(6)
      session[:phone] = params[:phone]
      session[:sms_token] = sms_token
      session[:sms_send_at] = Time.now
      User.send_validation_sms(sms_token, params[:phone])
    else
      Rails.logger.debug "SMS test mode is on, skipping sending the token"
    end

    render text: t('signup.notice')
  end

  def create
    if session[:sms_send_at].present? and
      Time.now > session[:sms_send_at] + User.sms_validate_within and
      !APP_CONFIG[:sms][:test_mode]
      flash.now[:error] = I18n.t('api.registration.sms.token_expired')
      @user = User.new
      render :new
    else
      @user = User.new(params.require(:user).permit(:email, :password, :phone, :sms_token))
      @user.sms_token_match_with(session[:phone], session[:sms_token])
      # Skip confirmation
      @user.skip_confirmation = true
      @user.confirm

      if @user.save
        session.delete(:phone)
        session.delete(:sms_token)
        session.delete(:sms_send_at)
        sign_in @user

        redirect_to mobile_registrations_step_one_url
      else
        @user.errors.delete :password_digest if @user.errors.messages.include? :password_digest
        flash.now[:error] = @user.errors.full_messages
        @user = User.new
        render :new
      end

    end

  end

  def step_one
    @profile = current_user.profile
    @profile.gender = 'male' unless %w(male female).include?(@profile.gender)
  end

  alias_method :step_two, :step_one
  alias_method :step_three, :step_one

  def css_namespace
    step_actions? ? 'registrations-controller' : super
  end

  private
  def step_actions?
    %w(step_one step_two step_three).include?(action_name)
  end
end
