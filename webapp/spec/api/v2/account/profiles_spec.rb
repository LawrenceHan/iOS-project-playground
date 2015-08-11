module V2::Account
  describe Profiles::API do
    let(:user) { create :user }
    let(:other_user) { create :user }
    before do
      @profile = create :profile, user: user
      login_as user
    end

    describe 'GET /v2/account/profiles/:id' do
      it 'gets my own profile' do
        get "/v2/account/profiles/#{user.id}"
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body['id']).to eq @profile.id
      end

      it 'gets other public profile' do
        another_user = create :user, phone: '15800681905'
        another_profile = create :profile, user: another_user
        get "/v2/account/profiles/#{another_user.id}"
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body['id']).to eq another_profile.id
        expect(parsed_body.keys).to match_array %w(id gender height weight user_id username thumb_avatar age country region city review_counts medical_experiences_count)
      end

      it 'gets an error if user not found' do
        get '/v2/account/profiles/0'
        expect(response.status).to eq 400
        expect(response.body).to eq JSON.generate(error: ['Can not found User with ID=0'])
      end
    end

    describe 'GET /v2/account/profiles/my' do
      it 'gets my own profile' do
        get '/v2/account/profiles/my'
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body['id']).to eq @profile.id
      end
    end

    describe 'PUT /v2/account/profile/my' do
      it 'updates my profile' do
        put '/v2/account/profiles/my', profile: {username: 'username'}
        expect(response.status).to eq 204
        @profile.reload
        expect(@profile.username).to eq 'username'
      end

      it 'fails to update with invalid attrs' do
        put '/v2/account/profiles/my', profile: {height: 10}
        expect(response.status).to eq 422
      end
    end
  end
end
