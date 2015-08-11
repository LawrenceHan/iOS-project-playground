module V2::Account
  describe Users::API do
    let(:user) { create :user }
    before {
      login_as user
      I18n.locale = "en"
    }

    describe 'PUT /v2/account/users/change_email' do
      it 'updates my unconfirmed_email' do
        expect(UserMailer).to receive(:confirm_email).and_return( double("Mailer", deliver: true) )
        put '/v2/account/users/change_email', { email: "test123@gmail.com" }
        expect(response.status).to eq 204
        expect(user.unconfirmed_email).to eq 'test123@gmail.com'
      end
    end

    describe 'PUT /v2/account/users/change_phone' do
      let(:user) { create :user }
      before { login_as user }
      it 'updates my phone' do
        expect(user).to receive(:sms_token_match_with).once.and_return(true)
        create :user, username: 'test123'
        put '/v2/account/users/change_phone', { phone: "15800681509", sms_token: '123456' }
        expect(response.status).to eq 204
        expect(user.phone).to eq '15800681509'
      end
    end
  end
end
