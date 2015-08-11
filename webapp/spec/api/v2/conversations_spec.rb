require 'rails_helper'

describe V2::Conversations::API do
  describe "GET /v2/conversations" do
    let(:user) { create(:user) }
    before do
      login_as user
      Admin.first.send_message(user, 'body1', 'subject1')
      Admin.first.send_message(user, 'body2', 'subject2')
      Mailboxer::Conversation.first.mark_as_read(user)
    end

    it 'returns all conversations' do
      get '/v2/conversations'
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['total_count']).to eq(2)
      expect(parsed_body['unread_count']).to eq(1)
      expect(parsed_body['results'].map { |conversation| conversation['subject'] }).to match_array %w(subject1 subject2)
      expect(parsed_body['results'].map { |conversation| conversation['body'] }).to match_array %w(body1 body2)
    end
  end

  describe "GET /v2/conversations/:id/messages" do
    let(:user) { create(:user) }
    let!(:conversation) { Admin.first.send_message(user, 'body', 'subject').notification.conversation }
    before { login_as user }

    it 'returns all conversations' do
      expect(conversation.reload.receipts.all?(&:is_read)).to be_falsey
      get "/v2/conversations/#{conversation.id}/messages"
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.first['subject']).to eq 'subject'
      expect(parsed_body.first['body']).to eq 'body'
      expect(conversation.reload.receipts.all?(&:is_read)).to be_truthy
    end
  end
end
