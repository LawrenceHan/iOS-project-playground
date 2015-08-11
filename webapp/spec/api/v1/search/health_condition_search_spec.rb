module V1::Search
  describe HealthConditionSearch::API do
    describe 'GET /v1/search/health_conditions' do
      let!(:health_condition1) { create :health_condition, name: 'Measles', category: 'Pediatrics' }
      let!(:health_condition2) { create :health_condition, name: 'Preterm birth', category: 'Gynecology' }
      let!(:health_condition3) { create :health_condition, name: 'Chicken pox', category: 'Pediatrics' }

      before do
        switch_locale 'zh-CN' do
          health_condition1.name = '麻疹'
          health_condition1.category = '儿科'
          health_condition1.save
          health_condition2.name = '早产'
          health_condition2.category = '妇科'
          health_condition2.save
          health_condition3.name = '水痘'
          health_condition3.category = '儿科'
          health_condition3.save
        end
      end

      it 'gets health_conditions by name in English' do
        get '/v1/search/health_conditions?name=Chicken&locale=en-US'
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.first['name']).to eq 'Pediatrics'
        expect(parsed_body.first['objects']).to eq [{"id" => health_condition3.id, "name" => 'Chicken pox', "type" => "HealthCondition"}]
      end

      it 'gets health_conditions by name in Chinese' do
        get "/v1/search/health_conditions?name=#{URI.encode('水痘')}&locale=zh-CN"
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.first['name']).to eq '儿科'
        expect(parsed_body.first['objects']).to match_array [{"id" => health_condition3.id, "name" => '水痘', "type" => "HealthCondition"}]
      end
    end
  end
end
