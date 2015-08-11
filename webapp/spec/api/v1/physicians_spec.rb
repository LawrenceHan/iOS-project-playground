require 'rails_helper'

describe V1::Physicians::API do
  describe "GET /v1/physicians/:id.json" do
    before do
      @physician = create :physician
    end

    it "returns a single physician" do
      get "/v1/physicians/#{@physician.id}.json"
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
        department_name
        hospital_name
        hospital_h_class
        question_avg_ratings
        vendor_id
        has_doc
      )
    end

    it "returns record not found error" do
      get "/v1/physicians/0.json"
      expect(response.status).to eq 400
      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to eq({"error" => ["Can not found Doctor with ID=0"]})
    end

    it "returns a single physician has_doc is false" do
      @physician = create :physician
      get "/v1/physicians/#{@physician.id}.json"
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['has_doc']).to eq(false)
    end

    it "returns a single physician has_doc is true" do
      @physician = create :physician, doc: { name: '金敏捷' }
      get "/v1/physicians/#{@physician.id}.json"
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['has_doc']).to eq(true)
    end

  end

  describe "GET /v1/physicians/:id.json (localized)" do
    it "returns a single physician (localized with English translation)" do
      @physician = create :physician, name: "齐志"
      get "/v1/physicians/#{@physician.id}.json", locale: 'en-US'
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['name']).to eq 'Qi Zhi'
    end

    it "returns a single physician (localized, test default to English)" do
      @physician = create :physician, name: "齐志"
      get "/v1/physicians/#{@physician.id}.json"
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['name']).to eq 'Qi Zhi'
    end

    it "returns a single physician (localized to Chinese)" do
      @physician = create :physician, name: "齐志"
      get "/v1/physicians/#{@physician.id}.json", locale: 'zh-CN'
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['name']).to eq '齐志'
    end

    it "returns a single physician (no translation)" do
      @physician = create :physician, name: "伍思力"
      get "/v1/physicians/#{@physician.id}.json", locale: 'en-US'
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['name']).to eq '伍思力'
    end
  end
  describe "GET /v1/physicians/:id/reviews" do
    let(:physician) { create :physician }
    before do
      create :physician_review, physician: physician
      @physician_reviews = create_list :physician_review, 2, physician: physician, status: 'published'
    end

    it "returns published physician reviews" do
      get "/v1/physicians/#{physician.id}/reviews", page: 1
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.map { |hr| hr['id'] }).to match_array @physician_reviews.map(&:id)
      expect(parsed_body.first.keys).to match_array %w(
        avg_rating
        created_at
        helpfuls_count
        human_conditions
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

  describe "GET /v1/physicians/:vendor_id/doc" do
    let(:hospital) { create :hospital, name: '上海市瑞金医院' }
    let(:physician) { create :physician, vendor_id: 'R00089213', doc: {name: '朱渊'}, hospital: hospital }

    it "returns physician doc with physician vendor_id" do
      get "/v1/physicians/#{physician.vendor_id}/doc", page: 1
      expect(response.status).to eq 200
      doc = JSON.parse(response.body)
      expect(doc).to eq('name' => '朱渊', 'hospital_name' => '上海市瑞金医院')
    end
  end

  describe "GET /v1/physicians/:id/doc" do
    let(:hospital) { create :hospital, name: '上海交通大学医学院附属瑞金医院' }
    let(:physician) { create :physician, vendor_id: 'M00013131', doc: {name: '张伟滨'}, hospital: hospital }

    it "returns physician doc with physician id" do
      get "/v1/physicians/#{physician.id}/doc", page: 1
      expect(response.status).to eq 200
      doc = JSON.parse(response.body)

      expect(doc).to eq('name' => '张伟滨', 'hospital_name' => '上海交通大学医学院附属瑞金医院')
    end
  end

  describe "GET /v1/physicians/:vendor_id/doc NOT FOUND" do
    it "returns physician doc with physician vendor_id" do
      get "/v1/physicians/R00089213/doc", page: 1

      expect(response.status).to eq 400
    end
  end

  describe "GET /v1/physicians/:id/doc NOT FOUND" do
    it "returns physician doc with physician id" do
      get "/v1/physicians/1/doc", page: 1

      expect(response.status).to eq 400
    end
  end

end
