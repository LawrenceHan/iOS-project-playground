module V2::Conversations
  class API < Grape::API
    helpers CommonHelper
    helpers AuthorizeHelper

    before do
      authenticate!
    end

    resource :conversations do
      desc "Return conversations"
      params do
        optional :page, type: Integer, desc: 'page number'
      end
      get do
        conversations = current_user.mailbox.inbox.page params[:page]
        unread_count = current_user.mailbox.inbox.unread(current_user).count

        { total_pages: conversations.total_pages, total_count: conversations.total_count, unread_count: unread_count, results: conversations.as_json(current_user: current_user) }
      end

      desc "Return messages in a conversation"
      params do
        requires :id, type: Integer, desc: 'Conversation id'
      end
      get ':id/messages', requirements: { id: /[0-9]*/ } do
        conversation = Mailboxer::Conversation.find(params[:id])
        conversation.mark_as_read(current_user)
        messages = conversation.messages

        say_succeed messages
      end
    end
  end
end
