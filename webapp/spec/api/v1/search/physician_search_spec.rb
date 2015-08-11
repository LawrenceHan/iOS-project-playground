module V1::Search
  describe PhysicianSearch::API do
    describe '/v1/search/physicians' do
      let(:hospital1) { create(:hospital, name: 'Shanghai hospital', latitude: "31.2123", longitude: "121.5123", avg_rating: '3.5') }
      let(:hospital2) { create(:hospital, name: 'New Delhi hospital', latitude: "28.6139", longitude: "77.2089", avg_rating: '4.5') }
      let(:department1) { create :department }
      let(:department2) { create :department }
      let(:speciality1) { create :speciality }
      let(:speciality2) { create :speciality }
      let(:physician1) { create :physician, hospital: hospital1, department: department1, name: 'test 123' }
      let(:physician2) { create :physician, hospital: hospital1, department: department1, name: 'tset 123' }
      let(:physician3) { create :physician, hospital: hospital2, department: department2, name: 'test 123' }
      before do
        create :departments_hospital, hospital: hospital1, department: department1
        create :departments_hospital, hospital: hospital2, department: department2
        create :physicians_speciality, physician: physician1, speciality: speciality1
        create :physicians_speciality, physician: physician2, speciality: speciality2
        create :physicians_speciality, physician: physician3, speciality: speciality1

        physician1.update_column :avg_rating, 3.5
        physician2.update_column :avg_rating, 4.5
        physician3.update_column :avg_rating, 4.0
      end

      it 'searches by name' do
        get '/v1/search/physicians?name=test'
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.map { |p| p['id'] }).to match_array [physician1.id, physician3.id]
        expect(parsed_body.map { |p| p['human_distance'] }).to match_array ["", ""]
      end

      it 'searches by hospital' do
        get "/v1/search/physicians?hospital_id=#{hospital1.id}"
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.map { |p| p['id'] }).to match_array [physician1.id, physician2.id]
      end

      it 'searches by department' do
        get "/v1/search/physicians?department_id=#{department1.id}"
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.map { |p| p['id'] }).to match_array [physician1.id, physician2.id]
      end

      it 'searches by speciality' do
        get "/v1/search/physicians?speciality_id=#{speciality1.id}"
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.map { |p| p['id'] }).to match_array [physician1.id, physician3.id]
      end

      it 'searches with distance' do
        get '/v1/search/physicians?name=test&lat=31.2&lng=121.5'
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.map { |p| p['id'] }).to match_array [physician1.id, physician3.id]
        expect(parsed_body.map { |p| p['human_distance'] }).to match_array ["1.8km", "4250.52km"]
      end

      it 'searches with ranking' do
        get '/v1/search/physicians?name=test&ranking=true'
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.map { |p| p['id'] }).to eq [physician3.id, physician1.id]
      end
    end
  end
end
