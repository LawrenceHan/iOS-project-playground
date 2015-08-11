module V2::Administrator
  describe Session::API do
    describe 'POST /v2/admin/session' do
      it 'signs in as an admin' do
        post '/v2/admin/session', admin: {email: 'jonathan.dairion@cegedim.com', password: '123456'}
        expect(response.status).to eq 201
      end

      it 'fails to sign in' do
        post '/v2/admin/session', admin: {email: 'jonathan.dairion@cegedim.com', password: '654321'}
        expect(response.status).to eq 401
        expect(response.body).to eq JSON.generate(error: 'Invalid email or password')
      end
    end
  end
end
