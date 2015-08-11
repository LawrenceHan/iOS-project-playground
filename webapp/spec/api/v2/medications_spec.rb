require 'rails_helper'

describe V1::Medications::API do
  describe "GET /v2/medications/:id.json" do
    before do
      @medication = create(:medication)
      @cardinal_health = create(:cardinal_health, :official_name => @medication.name)
      @medication.cardinal_health = @cardinal_health
      create :companies_medication, medication: @medication, begin_at: Time.now
    end

    it "returns a single medication" do
      get "/v2/medications/#{@medication.id}.json"
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to eq @medication.id
      expect(parsed_body.keys).to match_array %w(id name code avg_rating reviews_count company dosage question_avg_ratings cardinal_health)
    end

    it "returns record not found error" do
      get "/v2/medications/0.json"
      expect(response.status).to eq 400
      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to eq({"error" => ["Can not found Drugs with ID=0"]})
    end
  end

  describe "GET /v2/medications/:id/reviews" do
    let!(:medication) { create :medication }
    let!(:review) { create :medication_review, medication: medication }

    it "returns published medication reviews" do
      get "/v2/medications/#{medication.id}/reviews", page: 1
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.map { |hr| hr['id'] }).to eq [review.id]
      expect(parsed_body.first.keys).to match_array %w(id created_at helpfuls_count avg_rating note username user_id small_avatar reviewable_name
        medication_code medication_dosage medication_companies medication_avg_rating human_conditions human_symptoms human_health_conditions promoted)
    end
  end
end
