module V2::Administrator
  describe Users::API do
    let!(:user) { create :user, confirmed_at: nil}
    before { login_as Admin.first }

    describe 'PUT /v2/admin/users/:phone/verify' do
      it 'marks user active' do
        put "/v2/admin/users/98765432100/verify", sms_token: '1234'
        expect(response.status).to eq 200
        expect($redis.get('98765432100')).to eq '1234'
      end
    end
  end
end
