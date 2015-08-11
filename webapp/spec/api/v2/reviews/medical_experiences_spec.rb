module V1::Reviews
  describe MedicalExperiences::API do
    describe 'GET /v2/reviews/medical_experiences' do
      let(:user) { create :user}
      before do
        login_as user
        @medical_experiences = create_list :medical_experience, 2, user: user
      end

      it 'gets medical experiences list' do
        get '/v2/reviews/medical_experiences'
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.map { |me| me['id'] }).to match_array @medical_experiences.map(&:id)
        expect(parsed_body.first.keys).to match_array %w(id network_visible completion avg_rating created_at hospital_id review_data)
      end
    end

    describe 'GET /v2/reviews/medical_experiences/:id' do
      let(:user) { create :user }
      before do
        login_as user
        @medical_experience = create :medical_experience, user: user
      end

      it 'gets a medical_experience' do
        get "/v2/reviews/medical_experiences/#{@medical_experience.id}"
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body['id']).to eq @medical_experience.id
        expect(parsed_body.keys).to match_array %w(id completion updated_at behalf hospital_id network_visible conditions symptoms hospital_review physician_reviews medication_reviews)
      end

      it 'gets error if medical experience not found' do
        get '/v2/reviews/medical_experiences/0'
        expect(response.status).to eq 400
        expect(response.body).to eq JSON.generate(error: ["Can not found Medical experience with ID=0"])
      end
    end

    describe 'POST /v2/reviews/medical_experiences' do
      let(:user) { create :user }
      before { login_as user }

      it 'creates a medical experience' do
        expect {
          post '/v2/reviews/medical_experiences', medical_experience: {network_visible: true}
        }.to change { user.medical_experiences.count }.by(1)
        expect(response.status).to eq 201
      end
    end

    describe 'PUT /v2/reviews/medical_experiences/:id' do
      let(:user) { create :user }
      before do
        login_as user
        @medical_experience = create :medical_experience, user: user, network_visible: true
      end

      it 'updates a medical experience' do
        put "/v2/reviews/medical_experiences/#{@medical_experience.id}", medical_experience: {network_visible: false}
        expect(response.status).to eq 204
        @medical_experience.reload
        expect(@medical_experience.network_visible).to be_falsey
      end

      it 'fails to update a medical_experience if not found' do
        put '/v2/reviews/medical_experiences/0', medical_experience: {network_visible: false}
        expect(response.status).to eq 422
      end
    end

    describe 'POST /v2/reviews/medical_experiences/calculation_for_local' do
      it 'gets a new medical experience' do
        post '/v2/reviews/medical_experiences/calculation_for_local', medical_experience: {network_visible: true}
        expect(response.status).to eq 201
        parsed_body = JSON.parse(response.body)
        expect(parsed_body['id']).to be_nil
        expect(parsed_body['completion']).to eq 0.0
        expect(parsed_body['avg_rating']).to eq 0.0
      end
    end
  end
end
