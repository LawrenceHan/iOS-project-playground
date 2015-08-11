module V1::Account
  describe Users::API do
    let(:user) { create :user }
    before {
      login_as user
      I18n.locale = "en"
    }

    describe 'PUT /v1/account/users/my' do
      it 'updates my profile' do
        put '/v1/account/users/my', user: {email: "test123@gmail.com", phone: "15800681905"}
        expect(response.status).to eq 204
        expect(user.email).to eq 'test123@gmail.com'
        expect(user.phone).to eq '15800681905'
      end
    end

    describe 'PUT /v1/account/users/my' do
      it 'fails to update profile' do
        put '/v1/account/users/my', user: {email: '1', phone: '1'}
        expect(response.status).to eq 422
        expect(response.body).to eq JSON.generate({error: ["Email is invalid", "Phone is invalid"]})
      end
    end
  end
end
