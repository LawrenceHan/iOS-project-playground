module AdminPanel
  class MailboxerMessagesController < BaseController
    def index
      @mailboxer_receipts = Mailboxer::Receipt.where(receiver_type: 'User').page params[:page]
    end

    def new
      @mailboxer_message = Mailboxer::Message.new
    end
  end
end
