module V2::Account
  describe Password::API do
    describe 'POST /v2/account/password/recover' do
      before { create :user, email: 'test@test.com', phone: '15800681905' }

      it 'sends reset password instruction by email' do
        expect_any_instance_of(User).to receive(:send_reset_password_instructions)
        post '/v2/account/password/recover', email: 'test@test.com'
        expect(response.status).to eq 201
      end

      it 'sends reset password instruction by phone' do
        expect_any_instance_of(User).to receive(:send_reset_password_instructions_via_sms)
        post '/v2/account/password/recover', phone: '15800681905'
        expect(response.status).to eq 201
      end

      it 'fails to send reset password instruction if email does not match' do
        expect_any_instance_of(User).not_to receive(:send_reset_password_instructions)
        post '/v2/account/password/recover', email: 'tt@tt.com'
        expect(response.status).to eq 422
        expect(response.body).to eq JSON.generate(error: ['Email not found!'])
      end

      it 'fails to send reset password instruction if phone does not match' do
        expect_any_instance_of(User).not_to receive(:send_reset_password_instructions_via_sms)
        post '/v2/account/password/recover', phone: '15800680000'
        expect(response.status).to eq 422
        expect(response.body).to eq JSON.generate(error: ['Phone not found!'])
      end

      it 'fails to send reset password instruction if no email or phone provides' do
        post '/v2/account/password/recover'
        expect(response.status).to eq 422
        expect(response.body).to eq JSON.generate(error: ['Invalid call: email or phone does not exist'])
      end
    end

    describe 'POST /v2/account/password/update' do
      let(:user) { create :user, password: 'pass123' }
      before { login_as user }

      it 'resets password' do
        expect(user).to receive(:reset_password!).with('pass321', 'pass321').and_return(true)
        post '/v2/account/password/update', user: {current_password: 'pass123', password: 'pass321', password_confirmation: 'pass321'}
        expect(response.status).to eq 200
      end

      it 'fails to reset password with invalid current_password' do
        post '/v2/account/password/update', user: {current_password: 'pass321', password: 'pass321', password_confirmation: 'pass321'}
        expect(response.status).to eq 422
        expect(response.body).to eq JSON.generate(error: ['Current password not correct!'])
      end

      it 'fails to reset password' do
        expect(user).to receive(:reset_password!).with('pass321', 'pass321').and_return(false)
        post '/v2/account/password/update', user: {current_password: 'pass123', password: 'pass321', password_confirmation: 'pass321'}
        expect(response.status).to eq 422
      end
    end
  end
end
