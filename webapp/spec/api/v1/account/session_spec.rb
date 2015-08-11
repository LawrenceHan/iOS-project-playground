module V1::Account
  describe Session::API do
    before { @user = create :user, email: 'test@test.com', password: '123456' }

    describe 'POST /v1/account/session' do
      it 'logs in successfully' do
        post '/v1/account/session',
            {user: { email: 'test@test.com', password: '123456' }},
            { 'HTTP_USER_AGENT' => 'SUPERBROWSER/1.0' }
        expect(response.status).to eq 201
        t = TrackableLog.all.last
        expect(t.log['params']['user']['email']).to eq 'test@test.com'
        expect(t.log['params']['user']['password']).to eq nil
        expect(t.log['status']).to eq 201
        expect(t.log['REQUEST_URI']).to eq '/v1/account/session'
        expect(t.log['HTTP_USER_AGENT']).to eq 'SUPERBROWSER/1.0'
      end

      it 'fails to log in' do
        post '/v1/account/session', user: {email: 'test@test.com', password: '654321'}
        expect(response.status).to eq 401
        t = TrackableLog.all.last
        expect(t.log['exception']['action']).to eq 'unauthenticated'

      end
    end

    describe 'DELETE /v1/account/session' do
      before { login_as @user }

      it 'logs out' do
        delete '/v1/account/session'
        expect(response.status).to eq 204
        t = TrackableLog.all.last
        expect(t.log['status']).to eq 204
      end
    end
  end
end
