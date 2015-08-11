require 'rails_helper'

describe V1::Reviews::API do
  let(:user) { create :user }
  before { login_as user }

  describe 'POST /v2/reviews/:type' do
    it 'creates a review without health_condition_id for hospital' do
      hospital = create :hospital
      medical_experience = create :medical_experience, hospital: hospital, user: user
      expect {
        post '/v2/reviews/hospital', review: {reviewable_id: hospital.id, note: 'review note', medical_experience_id: medical_experience.id, answers_attributes: [attributes_for(:answer).to_json]}
      }.to change { Review.count }.by(1)
      expect(response.status).to eq 201
      review = Review.last
      expect(review.note).to eq('review note')
    end

    it 'creates a review with condition for hospital' do
      hospital = create :hospital
      medical_experience = create :medical_experience, hospital: hospital, user: user
      condition = create :condition, name: 'condition name'
      expect {
        post '/v2/reviews/hospital', review: {reviewable_id: hospital.id, note: 'review note', medical_experience_id: medical_experience.id, health_condition_id: condition.id, answers_attributes: [attributes_for(:answer).to_json]}
      }.to change { Review.count }.by(1)
      expect(response.status).to eq 201
      review = Review.last
      expect(review.note).to eq('review note')
      expect(review.human_conditions).to eq('condition name')
    end

    it 'creates a review with symptom for hospital' do
      hospital = create :hospital
      symptom = create :symptom, name: 'symptom name'
      expect {
        post '/v2/reviews/hospital', review: {reviewable_id: hospital.id, note: 'review note', health_condition_id: symptom.id, answers_attributes: [attributes_for(:answer).to_json]}
      }.to change { Review.count }.by(1)
      expect(response.status).to eq 201
      review = Review.last
      expect(review.note).to eq('review note')
      expect(review.human_symptoms).to eq('symptom name')
    end
  end

  describe 'GET /v2/reviews' do
    let(:medical_experience) { create :medical_experience, user: user }
    let(:hospital) { create :hospital, name: '瑞金医院' }
    let(:physician) { create :physician, name: '张三' }
    let(:medication) { create :medication, name: '阿司匹林' }
    let!(:hospital_review) { create :hospital_review, hospital: hospital, medical_experience: medical_experience }
    let!(:physician_review) { create :physician_review, physician: physician, medical_experience: medical_experience }
    let!(:medication_review) { create :medication_review, medication: medication, medical_experience: medical_experience }

    it 'gets reviews' do
      get "/v2/reviews"
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.map { |review_json| review_json['id'] }).to eq [medication_review.id, physician_review.id, hospital_review.id]
    end
  end

  describe 'GET /v2/reviews/:id' do
    let(:hospital) { create :hospital }
    let(:physician) { create :physician }
    let(:medication) { create :medication }
    let(:hospital_review) { create :hospital_review, hospital: hospital }
    let(:physician_review) { create :physician_review, physician: physician }
    let(:medication_review) { create :medication_review, medication: medication }

    it 'gets a hospital review' do
      get "/v2/reviews/#{hospital_review.id}"
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to eq hospital_review.id
    end

    it 'gets a physician review' do
      get "/v2/reviews/#{physician_review.id}"
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to eq physician_review.id
    end

    it 'gets a medication review' do
      get "/v2/reviews/#{medication_review.id}"
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to eq medication_review.id
    end

    it 'gets error when record not found' do
      get '/v2/reviews/0'
      expect(response.status).to eq 400
      expect(response.body).to eq JSON.generate(error: ["Can not found Review with ID=0"])
    end
  end

  describe '/v2/reviews/:id/helpful' do
    let(:hospital) { create :hospital }
    it 'gets error if review belongs to me' do
      hospital_review = create :hospital_review, user: user, hospital: hospital
      put "/v2/reviews/#{hospital_review.id}/helpful"
      expect(response.status).to eq 422
      expect(response.body).to eq JSON.generate(error: ['Cannot mark your own review as helpful'])
    end

    it 'marks review helpful' do
      hospital_review = create :hospital_review, hospital: hospital
      expect {
        put "/v2/reviews/#{hospital_review.id}/helpful"
      }.to change { Helpful.count }.by(1)
      expect(response.status).to eq 204
    end
  end

  describe 'PUT /v2/reviews/:id' do
    let(:hospital) { create :hospital }

    it 'updates review note' do
      hospital_review = create :hospital_review, hospital: hospital, user: user
      put "/v2/reviews/#{hospital_review.id}", id: hospital_review.id, review: {note: 'new note'}
      expect(response.status).to eq 204
      hospital_review.reload
      expect(hospital_review.note).to eq 'new note'
    end

    it 'fails to update review note after 24 hours' do
      hospital_review = nil
      Timecop.freeze 1.day.ago do
        hospital_review = create :hospital_review, hospital: hospital, user: user
      end
      put "/v2/reviews/#{hospital_review.id}", id: hospital_review.id, review: {note: 'new note'}
      expect(response.status).to eq 422
      expect(response.body).to eq JSON.generate(error: 'You can only edit a review within 24 hours')
    end
  end
end
