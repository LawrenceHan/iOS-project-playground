require 'rails_helper'

describe V2::Surveys::API do

  before do
    @survey_definition = create :survey_definition
    @survey_definition = @survey_definition.reload
  end

  describe "GET /v2/surveys/:uuid/definition.json" do

    it "returns a survey_definition" do
      get "/v2/surveys/#{@survey_definition.uuid}/definition.json"
      parsed_body = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(parsed_body['id']).to eq @survey_definition.id
      expect(parsed_body.keys).to match_array %w(
        id
        uuid
        definition
        survey_type
        created_at
        updated_at
        hospital_id
      )
    end

  end

  describe "POST /v2/surveys.json" do

    it "save a survey result success" do
      survey_result = build :survey_result
      post(
        "/v2/surveys.json",
        result: survey_result.result,
        survey_definition_id: @survey_definition.id
      )
      parsed_body = JSON.parse(response.body)
      expect(response.status).to eq 201
      expect(parsed_body['result']).to eq survey_result.result
      expect(parsed_body['survey_definition_id']).to eq @survey_definition.id
      expect(parsed_body.keys).to match_array %w(
        id
        result
        survey_definition_id
        created_at
        updated_at
      )
    end

  end

end
