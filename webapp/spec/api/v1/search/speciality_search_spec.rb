module V1::Search
  describe SpecialitySearch::API do
    describe 'GET /v1/search/specialities' do
      let!(:speciality1) { create :speciality, name: 'Pediatrics' }
      let!(:speciality2) { create :speciality, name: 'Gynecology' }

      before do
        switch_locale 'zh-CN' do
          speciality1.name = '儿科'
          speciality1.save
          speciality2.name = '妇科'
          speciality2.save
        end

        physician1 = create :physician
        physician2 = create :physician
        create :physicians_speciality, physician: physician1, speciality: speciality1
        create :physicians_speciality, physician: physician1, speciality: speciality2
        create :physicians_speciality, physician: physician2, speciality: speciality2
      end

      it 'searches in English' do
        get '/v1/search/specialities?locale=en-US'
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body).to match_array [
          {"id" => speciality1.id, "name" => 'Pediatrics', "physicians_count" => 1},
          {"id" => speciality2.id, "name" => 'Gynecology', "physicians_count" => 2}
        ]
      end

      it 'searches in Chinese' do
        get '/v1/search/specialities?locale=zh-CN'
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body).to match_array [
          {"id" => speciality1.id, "name" => '儿科', "physicians_count" => 1},
          {"id" => speciality2.id, "name" => '妇科', "physicians_count" => 2}
        ]
      end
    end
  end
end
