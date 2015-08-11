module AdminPanel
  class PushNotificationsController < BaseController
    #
    # Override the constructor so that it doesn't raise an error
    class Notification < APN::Notification
      def initialize(token, opts)
        @options = opts.is_a?(Hash) ? opts.symbolize_keys : {:alert => opts}
        @token = token
      end
    end


    def index
    end

    def create
      alert = params[:push_notification][:alert]
      notification = Notification.new(SampleToken, alert)

      if notification.payload_size > 256
        flash.now[:error] = I18n.t('messages.push_payload_too_long')
        render :index
      else
        tokens = if params[:push_notification][:user_phones].present?
                   user_phones = params[:push_notification][:user_phones].split("\r\n")
                   Profile.joins(:user).where("users.phone IN (?)", user_phones).pluck("profiles.ios_device_token")
                 else
                   Profile.select('distinct ios_device_token').where.not(ios_device_token: nil).pluck(:ios_device_token)
                 end
        Resque.enqueue(BatchIosNotification, tokens, alert) if tokens.size

        flash[:notice] = I18n.t('messages.successfully_sent_push_to_all')

        redirect_to action: :index
      end

    end

    SampleToken = '1' * 64

    def payload_size
      params[:push_notification].delete(:user_phones)
      notification = Notification.new(SampleToken, params[:push_notification])
      render text: notification.payload_size
    end
  end
end
