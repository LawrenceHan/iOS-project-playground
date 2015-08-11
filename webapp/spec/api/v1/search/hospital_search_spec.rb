module V1::Search
  describe HospitalSearch::API do
    let(:hospital1) { create(:hospital, name: 'Shanghai hospital', latitude: "31.2123", longitude: "121.5123") }
    let(:hospital2) { create(:hospital, name: 'New Delhi hospital', latitude: "28.6139", longitude: "77.2089") }
    before do
      hospital1.update_column :avg_rating, 3.5
      hospital2.update_column :avg_rating, 4.5
    end

    describe 'GET /v1/search/hospitals/nearby' do
      it 'gets both nearby hospitals' do
        get '/v1/search/hospitals/nearby?lat=31.2&lng=121.5&scope=10000.0'
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.size).to eq 2
        expect(parsed_body.first['name']).to eq 'Shanghai hospital'
        expect(parsed_body.last['name']).to eq 'New Delhi hospital'
      end

      it 'gets both nearby hospitals sorting by ranking' do
        get '/v1/search/hospitals/nearby?lat=31.2&lng=121.5&scope=10000.0&ranking=true'
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.size).to eq 2
        expect(parsed_body.map { |h| h['name'] }).to eq ['New Delhi hospital', 'Shanghai hospital']
      end

      it 'gets nearby Shanghai hospital' do
        get '/v1/search/hospitals/nearby?lat=31.2122&lng=121.5122&scope=1'
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.size).to eq 1
        expect(parsed_body.first['name']).to eq 'Shanghai hospital'
      end
    end

    describe 'GET /v1/search/hospitals/within_area' do
      it 'gets both nearby hospitals' do
        get '/v1/search/hospitals/within_area?lat=31.2&lng=121.5&sw_lat=28.0&sw_lng=77.2&ne_lat=32.2&ne_lng=122.5'
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.size).to eq 2
        expect(parsed_body.first['name']).to eq 'Shanghai hospital'
        expect(parsed_body.last['name']).to eq 'New Delhi hospital'
      end

      it 'gets both nearby hospitals sorting by ranking' do
        get '/v1/search/hospitals/within_area?lat=31.2&lng=121.5&sw_lat=28.0&sw_lng=77.2&ne_lat=32.2&ne_lng=122.5&ranking=true'
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.size).to eq 2
        expect(parsed_body.map { |h| h['name'] }).to eq ['New Delhi hospital', 'Shanghai hospital']
      end

      it 'gets nearby Shanghai hospital' do
        get '/v1/search/hospitals/within_area?lat=31.2&lng=121.5&sw_lat=31&sw_lng=121&ne_lat=32&ne_lng=122'
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.size).to eq 1
        expect(parsed_body.first['name']).to eq 'Shanghai hospital'
      end
    end

    describe 'GET /v1/search/hospitals/by_name' do
      it 'gets Shanghai hospital' do
        get '/v1/search/hospitals/by_name?name=Shanghai'
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.size).to eq 1
        expect(parsed_body.first['name']).to eq 'Shanghai hospital'
      end
    end

    describe 'GET /v1/search/hospitals/:id/departments' do
      let(:hospital) { create :hospital }
      before do
        @departments = create_list :department, 2
        @departments.each do |department|
          create :departments_hospital, hospital: hospital, department: department
          create :physician, hospital: hospital, department: department
        end
        create :department
      end

      it 'gets hospital\'s departments' do
        get "/v1/search/hospitals/#{hospital.id}/departments"
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.map { |d| d['id'] }).to match_array @departments.map(&:id)
      end

      it 'fails if hospital not found' do
        get '/v1/search/hospitals/0/departments'
        expect(response.status).to eq 400
        expect(response.body).to eq JSON.generate(error: ["Can not found Hospital with ID=0"])
      end
    end

    describe 'GET /v1/search/hospitals/:id/departments (localized)' do
      let(:hospital) { create :hospital }
      before do
        @names = ["Cosmetology", "Dentistry", "Dermatology", "General Medicine", "General Surgery", "Gynecology", "Neurology", "Oncology", "Pediatrics"]
        @localized = %w(儿科 肿瘤科 神经内科 妇科 普外科 全科 皮肤科 口腔科 医疗美容科)
        @departments = @names.each_with_index do |name, index|
          department = create :department, name: name
          switch_locale 'zh-CN' do
            department.name = @localized[index]
            department.save
          end
          create :departments_hospital, hospital: hospital, department: department
          create :physician, hospital: hospital, department: department
          department
        end
      end

      it 'gets hospital\'s departments (en-US)' do
        get "/v1/search/hospitals/#{hospital.id}/departments?locale=en-US"
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.map { |d| d['name'] }).to match_array @names
      end

      it 'gets hospital\'s departments (zh-CN)' do
        get "/v1/search/hospitals/#{hospital.id}/departments?locale=zh-CN"
        parsed_body = JSON.parse(response.body)
        expect(parsed_body.map { |d| d['name'] }).to match_array @localized
      end
    end
  end
end
