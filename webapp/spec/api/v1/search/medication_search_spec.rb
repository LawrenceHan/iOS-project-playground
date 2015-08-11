module V1::Search
  describe MedicationSearch::API do
    describe "GET /v1/search/medications" do
      before do
        @medication1 = create :medication, name: 'test 123', code: 'tset 123'
        @medication2 = create :medication, name: 'tset 123', code: 'test 123'
        @medication3 = create :medication, name: '123', code: '123'
      end

      it 'gets medications by name' do
        get '/v1/search/medications?name=test'
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.map { |m| m['id'] }).to match_array [@medication1.id, @medication2.id]
      end
    end
  end
end
