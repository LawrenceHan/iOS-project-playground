module V2::Account
  describe Session::API do
    before {
      @user = create :user, email: 'test@test.com', phone: '15800681905', password: '123456'
      create :user, email: '', phone: '15800681999', password: '654321'
    }

    describe 'POST /v2/account/session' do
      it 'logs in successfully with email' do
        post '/v2/account/session', user: {email: 'test@test.com', password: '123456'}
        expect(response.status).to eq 201
      end

      it 'logs in successfully with blank email and existing phone' do
        post '/v2/account/session', user: {email: '', phone: '15800681905', password: '123456'}
        expect(response.status).to eq 201
      end

      it 'logs in successfully with phone' do
        post '/v2/account/session', user: {phone: '15800681905', password: '123456'}
        expect(response.status).to eq 201
      end

      it 'fails to log in' do
        post '/v2/account/session', user: {email: 'test@test.com', password: '654321'}
        expect(response.status).to eq 401
      end
    end

    describe 'DELETE /v2/account/session' do
      before { login_as @user }

      it 'logs out' do
        delete '/v2/account/session'
        expect(response.status).to eq 204
      end
    end
  end
end
