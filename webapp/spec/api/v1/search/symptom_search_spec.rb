module V1::Search
  describe SymptomSearch::API do
    describe 'GET /v1/search/symptoms' do
      let!(:symptom1) { create :symptom, name: 'Measles', category: 'Pediatrics' }
      let!(:symptom2) { create :symptom, name: 'Preterm birth', category: 'Gynecology' }
      let!(:symptom3) { create :symptom, name: 'Chicken pox', category: 'Pediatrics' }

      before do
        switch_locale 'zh-CN' do
          symptom1.name = '麻疹'
          symptom1.category = '儿科'
          symptom1.save
          symptom2.name = '早产'
          symptom2.category = '妇科'
          symptom2.save
          symptom3.name = '水痘'
          symptom3.category = '儿科'
          symptom3.save
        end
      end

      it 'gets symptoms by name in English' do
        get '/v1/search/symptoms?name=Chicken&locale=en-US'
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.first['name']).to eq 'Pediatrics'
        expect(parsed_body.first['objects']).to eq [{"id" => symptom3.id, "name" => 'Chicken pox', "type" => "Symptom"}]
      end

      it 'gets symptoms by name in Chinese' do
        get "/v1/search/symptoms?name=#{URI.encode('水痘')}&locale=zh-CN"
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.first['name']).to eq '儿科'
        expect(parsed_body.first['objects']).to match_array [{"id" => symptom3.id, "name" => '水痘', "type" => "Symptom"}]
      end
    end
  end
end
