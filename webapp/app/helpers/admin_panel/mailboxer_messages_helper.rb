module AdminPanel
  module MailboxerMessagesHelper
    def receiver_phone(receipt)
      receipt.receiver.phone
    end
  end
end
