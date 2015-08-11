module V1::Search
  describe ConditionSearch::API do
    describe 'GET /v1/search/conditions' do
      let!(:condition1) { create :condition, name: 'Measles', category: 'Pediatrics' }
      let!(:condition2) { create :condition, name: 'Preterm birth', category: 'Gynecology' }
      let!(:condition3) { create :condition, name: 'Chicken pox', category: 'Pediatrics' }

      before do
        switch_locale 'zh-CN' do
          condition1.name = '麻疹'
          condition1.category = '儿科'
          condition1.save
          condition2.name = '早产'
          condition2.category = '妇科'
          condition2.save
          condition3.name = '水痘'
          condition3.category = '儿科'
          condition3.save
        end
      end

      it 'gets conditions by name in English' do
        get '/v1/search/conditions?name=Chicken&locale=en-US'
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.first['name']).to eq 'Pediatrics'
        expect(parsed_body.first['objects']).to eq [{"id" => condition3.id, "name" => 'Chicken pox', "type" => "Condition"}]
      end

      it 'gets conditions by name in Chinese' do
        get "/v1/search/conditions?name=#{URI.encode('水痘')}&locale=zh-CN"
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.first['name']).to eq '儿科'
        expect(parsed_body.first['objects']).to match_array [{"id" => condition3.id, "name" => '水痘', "type" => "Condition"}]
      end
    end
  end
end
