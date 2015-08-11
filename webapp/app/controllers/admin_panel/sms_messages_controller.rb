module AdminPanel
  class SmsMessagesController < BaseController
    def index
    end

    def create
      user_phones = if params[:sms_message][:user_phones].present?
                      params[:sms_message][:user_phones].split("\r\n")
                    else
                      User.pluck(:phone).compact
                    end
      Resque.enqueue(BatchSmsMessages, user_phones, params[:sms_message][:content])
      redirect_to admin_panel_sms_message_path, notice: 'Already sent'
    end
  end
end
