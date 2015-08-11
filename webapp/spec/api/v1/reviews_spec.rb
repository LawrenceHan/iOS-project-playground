require 'rails_helper'

describe V1::Reviews::API do
  let(:user) { create :user }
  before { login_as user }

  describe 'POST /v1/reviews/:type' do
    it 'creates a review for hospital' do
      hospital = create :hospital
      expect {
        post '/v1/reviews/hospital', review: {reviewable_id: hospital.id, answers_attributes: [attributes_for(:answer).to_json]}
      }.to change { Review.count }.by(1)
      expect(response.status).to eq 201
    end
  end

  describe 'GET /v1/reviews/:id' do
    let(:hospital) { create :hospital }
    let(:physician) { create :physician }
    let(:medication) { create :medication }
    let(:hospital_review) { create :hospital_review, hospital: hospital }
    let(:physician_review) { create :physician_review, physician: physician }
    let(:medication_review) { create :medication_review, medication: medication }

    it 'gets a hospital review' do
      get "/v1/reviews/#{hospital_review.id}"
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to eq hospital_review.id
    end

    it 'gets a physician review' do
      get "/v1/reviews/#{physician_review.id}"
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to eq physician_review.id
    end

    it 'gets a medication review' do
      get "/v1/reviews/#{medication_review.id}"
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to eq medication_review.id
    end

    it 'gets error when record not found' do
      get '/v1/reviews/0'
      expect(response.status).to eq 400
      expect(response.body).to eq JSON.generate(error: ["Can not found Review with ID=0"])
    end
  end

  describe '/v1/reviews/:id/helpful' do
    let(:hospital) { create :hospital }
    it 'gets error if review belongs to me' do
      hospital_review = create :hospital_review, user: user, hospital: hospital
      put "/v1/reviews/#{hospital_review.id}/helpful"
      expect(response.status).to eq 422
      expect(response.body).to eq JSON.generate(error: ['Cannot mark your own review as helpful'])
    end

    it 'marks review helpful' do
      hospital_review = create :hospital_review, hospital: hospital
      expect {
        put "/v1/reviews/#{hospital_review.id}/helpful"
      }.to change { Helpful.count }.by(1)
      expect(response.status).to eq 204
    end
  end

  describe 'PUT /v1/reviews/:id' do
    let(:hospital) { create :hospital }

    it 'updates review note' do
      hospital_review = create :hospital_review, hospital: hospital, user: user
      put "/v1/reviews/#{hospital_review.id}", id: hospital_review.id, review: {note: 'new note'}
      expect(response.status).to eq 204
      hospital_review.reload
      expect(hospital_review.note).to eq 'new note'
    end

    it 'fails to update review note after 24 hours' do
      hospital_review = nil
      Timecop.freeze 1.day.ago do
        hospital_review = create :hospital_review, hospital: hospital, user: user
      end
      put "/v1/reviews/#{hospital_review.id}", id: hospital_review.id, review: {note: 'new note'}
      expect(response.status).to eq 422
      expect(response.body).to eq JSON.generate(error: 'You can only edit a review within 24 hours')
    end
  end
end
