module V2::Account
  describe Confirmation::API do
    describe 'POST /v2/account/confirmation' do
      let(:user) { create :user }
      before { login_as user }

      it 'resends confirmation email' do
        expect(user).to receive(:send_confirmation_instructions)
        post '/v2/account/confirmation'
        expect(response.status).to eq 201
      end
    end
  end
end
