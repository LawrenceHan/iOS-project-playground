require 'rails_helper'

describe V1::Hospitals::API do
  describe "GET /v2/hospitals/:id.json" do
    before do
      @hospital = create(:hospital)
    end

    it "returns a single hospital" do
      get "/v2/hospitals/#{@hospital.id}.json"
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to eq @hospital.id
      expect(parsed_body.keys).to match_array %w(id name official_name h_class address phone post_code avg_rating reviews_count human_avg_waiting_time question_avg_ratings highly_reviews_departments ownership)
    end

    it "returns record not found error" do
      get "/v2/hospitals/0.json"
      expect(response.status).to eq 400
      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to eq({"error" => ["Can not found Hospital with ID=0"]})
    end
  end

  describe "GET /v2/hospitals/:id/reviews" do
    let!(:hospital) { create :hospital }
    let!(:review) { create :hospital_review, hospital: hospital }

    it "returns published hospital reviews" do
      get "/v2/hospitals/#{hospital.id}/reviews", page: 1
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.map { |row| row['id'] }).to eq [review.id]
      expect(parsed_body.first.keys).to match_array %w(id created_at helpfuls_count avg_rating note username user_id small_avatar reviewable_name
        hospital_h_class hospital_address hospital_avg_rating hospital_avg_waiting_time human_conditions human_symptoms human_health_conditions promoted)
    end
  end
end