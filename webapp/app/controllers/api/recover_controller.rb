module API
  class RecoverController < Base
    include ActionController::RequestForgeryProtection
    include Rails.application.routes.url_helpers

    before_action :set_locale

    def index
      @user = User.where(reset_password_token: params[:reset_password_token]).first
      if @user
        render "recover/index"
      else
        @message = I18n.t('api.password.token_invalid')
        render "recover/result"
      end
    end

    def update
      @user = User.reset_password_by_token(params[:user])
      if @user.errors.empty?
        @user.confirm!
        @message = I18n.t('api.password.password_changed')
        render "recover/result"
      else
        @message = @user.errors.full_messages.join(',')
        render "recover/index"
      end
    end

    protected

    def set_locale
      I18n.locale = params[:locale] || I18n.default_locale
    end
  end
end
