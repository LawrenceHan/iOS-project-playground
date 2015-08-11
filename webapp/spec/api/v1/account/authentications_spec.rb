module V1::Account
  describe Authentications::API do
    let(:user) { create :user }
    before { login_as user }

    describe 'POST /v1/account/authentications' do
      it 'binds twitter account' do
        expect {
          post '/v1/account/authentications', provider: 'twitter', token: 'twitter access token', uid: 'twitter uid', token_secret: 'twitter token secret'
        }.to change { Authentication.count }.by(1)
        expect(response.status).to eq 201
        user.reload
        expect(user.twitter_auth).not_to be_nil
      end

      it 'fails to bind twitter auth' do
        create :twitter_authentication, uid: 'twitter uid'
        expect {
          post '/v1/account/authentications', provider: 'twitter', token: 'twitter access token', uid: 'twitter uid'
        }.not_to change { Authentication.count }
        expect(response.status).to eq 422
      end
    end

    describe 'DELETE /v1/account/authentications/:provider' do
      it 'unlink twitter auth' do
        create :twitter_authentication, user: user
        expect {
          delete '/v1/account/authentications/twitter'
        }.to change { Authentication.count }.by(-1)
        expect(response.status).to eq 204
        user.reload
        expect(user.twitter_auth).to be_nil
      end
    end
  end
end
