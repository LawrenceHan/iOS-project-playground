module V1::Search
  describe ReviewSearch::API do
    let(:user) { create :user }
    before { login_as user }

    describe 'GET /v1/search/reviews/by_type' do
      before do
        @hospital_reviews = create_list :hospital_review, 2, status: 'published'
        @physician_reviews = create_list :physician_review, 2, status: 'published'
        @medication_reviews = create_list :medication_review, 2, status: 'published'
      end

      it 'gets reviews by hospital' do
        get '/v1/search/reviews/by_type?type=hospital'
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.map { |r| r['id'] }).to match_array @hospital_reviews.map(&:id)
      end

      it 'gets reviews by physician' do
        get '/v1/search/reviews/by_type?type=physician'
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.map { |r| r['id'] }).to match_array @physician_reviews.map(&:id)
      end

      it 'gets reviews by medication' do
        get '/v1/search/reviews/by_type?type=medication'
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.map { |r| r['id'] }).to match_array @medication_reviews.map(&:id)
      end
    end

    describe 'GET /v1/search/reviews/by_medication' do
      let(:medication) { create :medication }
      before do
        @medication_reviews = create_list :medication_review, 2, status: 'published', medication: medication
        create :medication_review, status: 'published'
      end

      it 'gets reviews by medication id' do
        get "/v1/search/reviews/by_medication?medication_id=#{medication.id}"
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.map { |r| r['id'] }).to match_array @medication_reviews.map(&:id)
      end
    end

    describe 'GET /v1/search/reviews/by_hospital' do
      let(:hospital) { create :hospital }
      before do
        @hospital_reviews = create_list :hospital_review, 2, status: 'published', hospital: hospital
        create :hospital_review, status: 'published'
      end

      it 'gets reviews by hospital id' do
        get "/v1/search/reviews/by_hospital?hospital_id=#{hospital.id}"
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.map { |r| r['id'] }).to match_array @hospital_reviews.map(&:id)
      end
    end

    describe 'GET /v1/search/reviews/by_user' do
      let(:user1) { create :user }
      let(:user2) { create :user }
      let(:medical_experience1) { create :medical_experience, user: user1 }
      let(:medical_experience2) { create :medical_experience, user: user2 }

      before do
        @hospital_review1 = create :hospital_review, status: 'published', medical_experience: medical_experience1
        @hospital_review2 = create :hospital_review, status: 'published', medical_experience: medical_experience2
        @physician_review1 = create :physician_review, status: 'published', medical_experience: medical_experience1
        @physician_review2 = create :physician_review, status: 'published', medical_experience: medical_experience2
        @medication_review1 = create :medication_review, status: 'published', medical_experience: medical_experience1
        @medication_review2 = create :medication_review, status: 'published', medical_experience: medical_experience2
      end

      it 'searches hospital reviews by user1' do
        get "/v1/search/reviews/by_user?user_id=#{user1.id}&type=hospital"
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.first['id']).to eq @hospital_review1.id
      end

      it 'searches physician reviews by user1' do
        get "/v1/search/reviews/by_user?user_id=#{user1.id}&type=physician"
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.first['id']).to eq @physician_review1.id
      end

      it 'searches medication reviews by user1' do
        get "/v1/search/reviews/by_user?user_id=#{user1.id}&type=medication"
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.first['id']).to eq @medication_review1.id
      end
    end
  end
end
