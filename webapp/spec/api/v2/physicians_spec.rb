# So far it's copy from spec/api/v1/physician_spec.rb
# Just replace all v1 to v2

require 'rails_helper'

describe V2::Physicians::API do
  describe "GET /v2/physicians/:id.json" do
    before do
      @physician = create :physician
    end

    it "returns a single physician" do
      get "/v2/physicians/#{@physician.id}.json"
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to eq @physician.id
      expect(parsed_body.keys).to match_array %w(
        id
        hospital_id
        name
        gender
        position
        avg_rating
        reviews_count
        human_avg_waiting_time
        human_avg_price
        human_specialities
        age
        thumb_avatar
        department_name
        department_phone
        hospital_name
        hospital_h_class
        question_avg_ratings
        vendor_id
        doc
        has_doc
      )
    end

    it "returns record not found error" do
      get "/v2/physicians/0.json"
      expect(response.status).to eq 400
      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to eq({"error" => ["Can not found Doctor with ID=0"]})
    end

    it "returns a single physician has_doc is false" do
      @physician = create :physician
      get "/v2/physicians/#{@physician.id}.json"
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['has_doc']).to eq(false)
    end

    it "returns a single physician has_doc is true" do
      @physician = create :physician, doc: { name: '金敏捷' }
      get "/v2/physicians/#{@physician.id}.json"
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['has_doc']).to eq(true)
    end

  end
  describe "GET /v2/physicians/:id/reviews" do
    let!(:physician) { create :physician }
    let!(:review) { create :physician_review, physician: physician }

    it "returns published physician reviews" do
      get "/v2/physicians/#{physician.id}/reviews", page: 1
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.map { |hr| hr['id'] }).to eq [review.id]
      expect(parsed_body.first.keys).to match_array %w(
        avg_rating
        created_at
        helpfuls_count
        human_conditions
        human_symptoms
        human_health_conditions
        id
        note
        physician_avg_rating
        physician_gender
        physician_position
        promoted
        reviewable_name
        small_avatar
        user_id
        username
      )
    end
  end

  describe "GET /v2/physicians/:vendor_id/doc" do
    let(:hospital) { create :hospital, name: '上海市瑞金医院' }
    let(:physician) { create :physician, vendor_id: 'R00089213', doc: {name: '朱渊'}, hospital: hospital }

    it "returns physician doc with physician vendor_id" do
      get "/v2/physicians/#{physician.vendor_id}/doc", page: 1
      expect(response.status).to eq 200
      doc = JSON.parse(response.body)
      expect(doc).to eq('name' => '朱渊', 'hospital_name' => '上海市瑞金医院')
    end
  end

  describe "GET /v2/physicians/:id/doc" do
    let(:hospital) { create :hospital, name: '上海交通大学医学院附属瑞金医院' }
    let(:physician) { create :physician, vendor_id: 'M00013131', doc: {name: '张伟滨'}, hospital: hospital }

    it "returns physician doc with physician id" do
      get "/v2/physicians/#{physician.id}/doc", page: 1
      expect(response.status).to eq 200
      doc = JSON.parse(response.body)

      expect(doc).to eq('name' => '张伟滨', 'hospital_name' => '上海交通大学医学院附属瑞金医院')
    end
  end

  describe "GET /v2/physicians/:uuid/doc" do
    let(:hospital) { create :hospital, name: '上海交通大学医学院附属瑞金医院' }
    let(:physician) { create :physician, vendor_id: '417ddfd9-625b-4df5-b2d9-149f4e7b9861', doc: {name: '赵燕茹'}, hospital: hospital }

    it "returns physician doc with physician uuid" do
      get "/v2/physicians/#{physician.vendor_id}/doc", page: 1
      expect(response.status).to eq 200
      doc = JSON.parse(response.body)

      expect(doc).to eq('name' => '赵燕茹', 'hospital_name' => '上海交通大学医学院附属瑞金医院')
    end
  end

  describe "GET /v2/physicians/:vendor_id/doc NOT FOUND" do
    it "returns physician doc with physician vendor_id" do
      get "/v2/physicians/R00089213/doc", page: 1

      expect(response.status).to eq 400
    end
  end

  describe "GET /v2/physicians/:id/doc NOT FOUND" do
    it "returns physician doc with physician id" do
      get "/v2/physicians/1/doc", page: 1

      expect(response.status).to eq 400
    end
  end
end
