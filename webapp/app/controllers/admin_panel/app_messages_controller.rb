module AdminPanel
  class AppMessagesController < BaseController
    def index
    end

    def create
      user_ids = if params[:app_message][:user_phones].present?
                   User.where(phone: params[:app_message][:user_phones].split("\r\n")).pluck(:id)
                 else
                   User.pluck(:id)
                 end
      Resque.enqueue(BatchAppMessages, user_ids, params[:app_message][:subject], params[:app_message][:content], current_admin.id)
      redirect_to admin_panel_app_message_path, notice: 'Already sent'
    end
  end
end
