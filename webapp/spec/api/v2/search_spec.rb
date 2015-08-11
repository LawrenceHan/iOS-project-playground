require 'rails_helper'

describe V2::Search::API do
  context 'Hospital' do
    let!(:hospital1) { create(:hospital, name: 'Shanghai Hospital', latitude: "31.2123", longitude: "121.5123", h_class: '二级乙等') }
    let!(:hospital2) { create(:hospital, name: 'New Shanghai Hospital', latitude: "32.2123", longitude: "122.5123", h_class: '三级甲等') }
    let!(:hospital3) { create(:hospital, name: 'New Delhi hospital', latitude: "28.6139", longitude: "77.2089") }
    let!(:department1) { create :department, name: 'Pediatrics' }
    let!(:department2) { create :department, name: 'Gynecology' }
    let!(:hospital1_reviews) { create_list(:hospital_review, 20, status: 'published', hospital: hospital1) }
    let!(:hospital2_reviews) { create_list(:hospital_review, 10, status: 'published', hospital: hospital2) }
    let!(:hospital3_reviews) { create_list(:hospital_review, 30, status: 'published', hospital: hospital3) }
    before do
      switch_locale 'zh-CN' do
        hospital1.name = '上海医院'
        hospital1.save
        hospital2.name = '新上海医院'
        hospital2.save
        hospital3.name = '新德里医院'
        hospital3.save
        department1.name = '儿科'
        department1.save
        department2.name = '妇科'
        department2.save
      end
      create :departments_hospital, hospital: hospital1, department: department1
      create :departments_hospital, hospital: hospital2, department: department1
      create :departments_hospital, hospital: hospital3, department: department2
      hospital1_reviews.each { |review| review.update_column :avg_rating, 3.0 } # hospital 1 average rating is 3.0
      hospital2_reviews.each_with_index { |review, index| review.update_column :avg_rating, index % 2 == 0 ? 4.0 : 5.0 } # hospital2 average rating is 4.5
      hospital3_reviews.each { |review| review.update_column :avg_rating, 4.0 } # hospital 3 average rating is 4.0
    end

    describe 'search nearby' do
      it 'gets both nearby hospitals' do
        post '/v2/search', { query: { type: 'Hospital', nearby: { lat: 31.2, lng: 121.5, distance: 1000.0 } } }
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        results = parsed_body['results']
        expect(results.size).to eq 2
        expect(results.first['name']).to eq hospital1.name
        expect(results.last['name']).to eq hospital2.name
      end

      it 'gets both nearby hospitals sorting by reviews_count' do
        post '/v2/search', { query: { type: 'Hospital', nearby: { lat: 31.2, lng: 121.5, distance: 1000.0 } }, sort: { reviews_count: true } }
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        results = parsed_body['results']
        expect(results.size).to eq 2
        expect(results.map { |hospital| hospital['id'] }).to eq [hospital1.id, hospital2.id]
        expect(results.map { |hospital| hospital['reviews_count'] }).to eq [20, 10]
      end

      it 'gets both nearby hospitals sorting by h_class' do
        post '/v2/search', { query: { type: 'Hospital', nearby: { lat: 31.2, lng: 121.5, distance: 1000.0 } }, sort: { h_class: true } }
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        results = parsed_body['results']
        expect(results.size).to eq 2
        expect(results.map { |hospital| hospital['name'] }).to eq [hospital2.name, hospital1.name]
      end

      it 'gets nearby 上海医院' do
        post '/v2/search', { query: { type: 'Hospital', nearby: { lat: 31.2122, lng: 121.5122, distance: 1.0 } } }
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        results = parsed_body['results']
        expect(results.size).to eq 1
        expect(results.first['name']).to eq hospital1.name
      end
    end

    describe 'search within area' do
      it 'gets both hospitals within area' do
        post '/v2/search', { query: { type: 'Hospital', area: { lat: 31.2, lng: 121.5, sw_lat: 28.0, sw_lng: 77.2, ne_lat: 32.2, ne_lng: 122.5 } } }
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        results = parsed_body['results']
        expect(results.size).to eq 2
        expect(results.map { |hospital| hospital['name'] }).to eq [hospital1.name, hospital3.name]
      end

      it 'gets both hospitals within area sorting by ranking' do
        post '/v2/search', { query: { type: 'Hospital', area: { lat: 31.2, lng: 121.5, sw_lat: 28.0, sw_lng: 77.2, ne_lat: 32.2, ne_lng: 122.5 } }, sort: { ranking: true } }
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        results = parsed_body['results']
        expect(results.size).to eq 2
        expect(results.map { |hospital| hospital['name'] }).to eq [hospital3.name, hospital1.name]
      end

      it 'gets 上海医院 within area' do
        post '/v2/search', { query: { type: 'Hospital', area: { lat: 31.2, lng: 121.5, sw_lat: 31, sw_lng: 121, ne_lat: 32, ne_lng: 122 } } }
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        results = parsed_body['results']
        expect(results.size).to eq 1
        expect(results.first['name']).to eq hospital1.name
      end
    end

    describe 'search by name' do
      it 'gets hospitals, query by name 上海, sort by ranking' do
        post '/v2/search', { query: { type: 'Hospital', text: '上海' }, sort: { ranking: true } }
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        results = parsed_body['results']
        expect(results.size).to eq 2
        expect(results.map { |hospital| hospital['name'] }).to eq [hospital1.name, hospital2.name]
      end

      it 'gets hospitals, query by name 上海, sort by distance' do
        post '/v2/search', { query: { type: 'Hospital', text: '上海' }, sort: { distance: { lat: 23.0, lng: 100.0 } } }
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        results = parsed_body['results']
        expect(results.size).to eq 2
        expect(results.map { |hospital| hospital['name'] }).to eq [hospital1.name, hospital2.name]
      end

      it 'gets hospital with attrs id, class_name, name, address, h_class, avg_rating, latitude, longitude, reviews_count, human_distance' do
        post '/v2/search', { query: { text: 'Delhi' } }
        expect(response.status).to eq 200
        parsed_body = JSON.parse(response.body)
        results = parsed_body['results']
        expect(results.size).to eq 1
        expect(results.first.keys).to match_array(%w(id class_name name address h_class avg_rating latitude longitude reviews_count human_distance))
      end
    end

    it 'searches name in English' do
      post '/v2/search?locale=en-US', { query: { type: 'Hospital', text: 'Shanghai' }, sort: { ranking: true } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.size).to eq 2
      expect(results.map { |hospital| hospital['name'] }).to eq ['Shanghai Hospital', 'New Shanghai Hospital']
    end

    it 'searches name in Chinese' do
      post '/v2/search?locale=zh-CN', { query: { type: 'Hospital', text: '上海' }, sort: { ranking: true } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.size).to eq 2
      expect(results.map { |hospital| hospital['name'] }).to eq ['上海医院', '新上海医院']
    end

    it 'searches from department' do
      post '/v2/search', { query: { type: 'Hospital', text: '儿' }, sort: { ranking: true } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.size).to eq 2
      expect(results.map { |r| r['name']}).to eq [hospital1.name, hospital2.name]
    end

    it 'searches all, sort by ranking' do
      post '/v2/search', { query: { type: 'Hospital' }, sort: { ranking: true } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.size).to eq 3
      expect(results.map { |hospital| hospital['id'] }).to eq [hospital3.id, hospital1.id, hospital2.id] # hospital 2 has < 16 review
    end
  end

  context 'Physician' do
    let!(:hospital1) { create(:hospital, name: 'Shanghai Hospital', latitude: "31.2123", longitude: "121.5123", h_class: '二级乙等') }
    let!(:hospital2) { create(:hospital, name: 'New Delhi Hospital', latitude: "28.6139", longitude: "77.2089", h_class: '三级甲等') }
    let!(:department1) { create :department, name: 'Pediatrics' }
    let!(:department2) { create :department, name: 'Gynecology' }
    let!(:physician1) { create :physician, hospital: hospital1, department: department1, name: 'Zhang San' }
    let!(:physician2) { create :physician, hospital: hospital1, department: department1, name: 'Wang Wu' }
    let!(:physician3) { create :physician, hospital: hospital2, department: department2, name: 'Zhang Si' }
    let!(:physician4) { create :physician, hospital: hospital1, department: department2, name: 'Wang Si' }
    let!(:speciality1) { create :speciality }
    let!(:speciality2) { create :speciality }
    let!(:physician1_reviews) { create_list(:physician_review, 6, status: 'published', physician: physician1) }
    let!(:physician2_reviews) { create_list(:physician_review, 4, status: 'published', physician: physician2) }
    let!(:physician3_reviews) { create_list(:physician_review, 8, status: 'published', physician: physician3) }
    before do
      switch_locale 'zh-CN' do
        hospital1.name = '上海医院'
        hospital1.save
        hospital2.name = '新德里医院'
        hospital2.save
        department1.name = '儿科'
        department1.save
        department2.name = '妇科'
        department2.save
        physician1.name = '张三'
        physician1.save
        physician2.name = '王五'
        physician2.save
        physician3.name = '张思'
        physician3.save
        physician4.name = '王思'
        physician4.save
      end

      create :departments_hospital, hospital: hospital1, department: department1
      create :departments_hospital, hospital: hospital2, department: department2
      create :physicians_speciality, physician: physician1, speciality: speciality1
      create :physicians_speciality, physician: physician2, speciality: speciality2
      create :physicians_speciality, physician: physician3, speciality: speciality1
      create :physicians_speciality, physician: physician4, speciality: speciality2

      physician1_reviews.each { |review| review.update_column :avg_rating, 3.0 } # physcian1 avg_rating is 3.0
      physician2_reviews.each_with_index { |review, index| review.update_column :avg_rating, index % 2 == 0 ? 4.0 : 5.0 } # physician2 avg_rating is 4.5
      physician3_reviews.each { |review| review.update_column :avg_rating, 4.0 } # physcian3 avg_rating is 4.0
    end

    it 'gets physician with attrs id, class_name, hospital_id, name, gender, avg_rating, position, reviews_count, age, human_distance, department_name, human_specialities, hospital_name, hospital_h_class' do
      post '/v2/search', { query: { text: 'Wang Wu' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.size).to eq 1
      expect(results.first.keys).to match_array(%w(id class_name hospital_id name gender avg_rating position reviews_count age thumb_avatar human_distance department_name department_phone human_specialities hospital_name hospital_h_class))
    end

    it 'searches by name' do
      post '/v2/search', { query: { text: 'Zhang' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 2
      expect(results.map { |p| p['id'] }).to match_array [physician1.id, physician3.id]
    end

    it 'searches by hospital' do
      post '/v2/search', { query: { hospital_id: hospital1.id, type: 'Physician' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 3
      expect(results.map { |p| p['id'] }).to match_array [physician1.id, physician2.id, physician4.id]
    end

    it 'searches by department' do
      post '/v2/search', { query: { department_id: department1.id, type: 'Physician' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 2
      expect(results.map { |p| p['id'] }).to match_array [physician1.id, physician2.id]
    end

    it 'searches by speciality' do
      post '/v2/search', { query: { speciality_id: speciality1.id, type: 'Physician' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 2
      expect(results.map { |p| p['id'] }).to match_array [physician1.id, physician3.id]
    end

    it 'gets physicians, nearby 上海医院' do
      post '/v2/search', { query: { type: 'Physician', nearby: { lat: 31.2122, lng: 121.5122, distance: 1.0 } } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 3
      expect(results.map { |p| p['id'] }).to match_array [physician1.id, physician2.id, physician4.id]
    end

    it 'searches with distance' do
      post '/v2/search', { query: { text: 'Zhang' }, sort: { distance: { lat: 31.2, lng: 121.5 } } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 2
      expect(results.map { |p| p['id'] }).to eq [physician1.id, physician3.id]
      expect(results.map { |p| p['human_distance'] }).to eq ["1.8km", "4250.52km"]
    end

    it 'searches with ranking' do
      post '/v2/search', { query: { type: 'Physician' }, sort: { ranking: true } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 4
      expect(results.map { |p| p['id'] }).to eq [physician3.id, physician1.id, physician2.id, physician4.id]
      expect(results.map { |p| p['avg_rating'] }).to eq [4.0, 3.0, 4.5, 0.0]
    end

    it 'searches with reviews_count' do
      post '/v2/search', { query: { type: 'Physician' }, sort: { reviews_count: true } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 4
      expect(results.map { |p| p['id'] }).to eq [physician3.id, physician1.id, physician2.id, physician4.id]
      expect(results.map { |p| p['reviews_count'] }).to eq [8, 6, 4, 0]
    end

    it 'searches with h_class' do
      post '/v2/search', { query: { text: 'Zhang' }, sort: { h_class: true } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 2
      expect(results.map { |p| p['id'] }).to eq [physician3.id, physician1.id]
    end

    it 'searches by department name' do
      post '/v2/search', { query: { type: 'Physician', text: '儿科' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 2
      expect(results.map { |p| p['id'] }).to match_array [physician1.id, physician2.id]
    end

    it 'searches by hospital name' do
      post '/v2/search', { query: { type: 'Physician', text: '上海' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 3
      expect(results.map { |p| p['id'] }).to match_array [physician1.id, physician2.id, physician4.id]
    end

    it 'searches by hospital and department name' do
      post '/v2/search', { query: { type: 'Physician', text: '上海妇科' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 1
      expect(results.map { |p| p['id'] }).to match_array [physician4.id]
    end

    it 'searches in English' do
      post '/v2/search?locale=en-US', { query: { text: 'Wang Wu' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.size).to eq 1
      expect(results.first['name']).to eq 'Wang Wu'
    end

    it 'searches in Chinese' do
      post '/v2/search?locale=zh-CN', { query: { text: '王五' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.size).to eq 1
      expect(results.first['name']).to eq '王五'
    end
  end

  context 'Medication' do
    let!(:cardinal_health1) { create(:cardinal_health) }
    let!(:cardinal_health2) { create(:cardinal_health) }
    let!(:cardinal_health3) { create(:cardinal_health) }
    let!(:medication1) { create :medication, name: 'Jin Ge', code: 'jinge 123', cardinal_health: cardinal_health1 }
    let!(:medication2) { create :medication, name: 'Jin Ge', code: 'jinge 321', cardinal_health: cardinal_health2 }
    let!(:medication3) { create :medication, name: 'Aspirin', code: 'asipilin 123', cardinal_health: cardinal_health3 }
    let!(:review1) { create(:medication_review, status: 'published', medication: medication1) }
    let!(:review2) { create(:medication_review, status: 'published', medication: medication2) }
    let!(:review3) { create(:medication_review, status: 'published', medication: medication2) }
    let!(:review4) { create(:medication_review, status: 'published', medication: medication3) }
    let!(:review5) { create(:medication_review, status: 'published', medication: medication3) }
    let!(:review6) { create(:medication_review, status: 'published', medication: medication3) }
    before do
      switch_locale 'zh-CN' do
        medication1.name = '金戈'
        medication1.save
        medication2.name = '金戈'
        medication2.save
        medication3.name = '阿司匹林'
        medication3.save
      end

      review1.update_column :avg_rating, 3.0
      review2.update_column :avg_rating, 4.0
      review3.update_column :avg_rating, 5.0
      review4.update_column :avg_rating, 4.0
      review5.update_column :avg_rating, 4.0
      review6.update_column :avg_rating, 4.0
    end

    it 'gets medications by name' do
      post '/v2/search', { query: { text: '金戈' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 2
      expect(results.map { |m| m['id'] }).to match_array [medication1.id, medication2.id]
      expect(results.first.keys).to match_array %w(id name class_name code avg_rating reviews_count companies company dosage question_avg_ratings cardinal_health)
    end

    it 'gets medications by name, sort by ranking' do
      post '/v2/search', { query: { type: 'Medication' }, sort: { ranking: true } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 3
      expect(results.map { |m| m['id'] }).to eq [medication2.id, medication3.id, medication1.id]
      expect(results.map { |m| m['avg_rating'] }).to eq [4.5, 4.0, 3.0]
    end

    it 'gets medications by name, sort by reviews_count' do
      post '/v2/search', { query: { type: 'Medication' }, sort: { ranking: true, reviews_count: true } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 3
      expect(results.map { |m| m['id'] }).to eq [medication3.id, medication2.id, medication1.id]
      expect(results.map { |m| m['reviews_count'] }).to eq [3, 2, 1]
    end

    it 'searches in English' do
      post '/v2/search?locale=en-US', { query: { text: 'Jin Ge' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 2
      expect(results.map { |m| m['name'] }).to eq ['Jin Ge', 'Jin Ge']
    end

    it 'searches in Chinese' do
      post '/v2/search?locale=zh-CN', { query: { text: '金戈' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 2
      expect(results.map { |m| m['name'] }).to eq ['金戈', '金戈']
    end
  end

  context "Condition" do
    let!(:condition1) { create :condition, name: 'Measles', category: 'Pediatrics' }
    let!(:condition2) { create :condition, name: 'Chicken pox', category: 'Pediatrics' }
    let!(:condition3) { create :condition, name: 'Preterm birth', category: 'Gynecology' }
    let!(:condition4) { create :condition, name: 'Infertility', category: 'Gynecology' }

    before do
      switch_locale 'zh-CN' do
        condition1.name = '麻疹'
        condition1.category = '儿科'
        condition1.save
        condition2.name = '水痘'
        condition2.category = '儿科'
        condition2.save
        condition3.name = '早产'
        condition3.category = '妇科'
        condition3.save
        condition4.name = '不孕症'
        condition4.category = '妇科'
        condition4.save
      end
    end

    it 'searches in English' do
      post '/v2/search?locale=en-US', { query: { text: 'Infertility' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 1
      expect(results.first['name']).to eq 'Gynecology'
      expect(results.first['objects'].first['name']).to eq 'Infertility'
      expect(results.first['objects'].first['type']).to eq 'Condition'
    end

    it 'searches in Chinese' do
      post '/v2/search?locale=zh-CN', { query: { text: '水痘' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 1
      expect(results.first['name']).to eq '儿科'
      expect(results.first['objects'].first['name']).to eq '水痘'
      expect(results.first['objects'].first['type']).to eq 'Condition'
    end
  end

  context "HealthCondition" do
    let!(:condition1) { create :health_condition, name: 'Measles', category: 'Pediatrics' }
    let!(:condition2) { create :health_condition, name: 'Chicken pox', category: 'Pediatrics' }
    let!(:condition3) { create :health_condition, name: 'Preterm birth', category: 'Gynecology' }
    let!(:condition4) { create :health_condition, name: 'Infertility', category: 'Gynecology' }

    before do
      switch_locale 'zh-CN' do
        condition1.name = '麻疹'
        condition1.category = '儿科'
        condition1.save
        condition2.name = '水痘'
        condition2.category = '儿科'
        condition2.save
        condition3.name = '早产'
        condition3.category = '妇科'
        condition3.save
        condition4.name = '不孕症'
        condition4.category = '妇科'
        condition4.save
      end
    end

    it 'searches in English' do
      post '/v2/search?locale=en-US', { query: { text: 'Infertility' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 1
      expect(results.first['name']).to eq 'Gynecology'
      expect(results.first['objects'].first['name']).to eq 'Infertility'
      expect(results.first['objects'].first['type']).to eq 'HealthCondition'
    end

    it 'searches in Chinese' do
      post '/v2/search?locale=zh-CN', { query: { text: '水痘' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 1
      expect(results.first['name']).to eq '儿科'
      expect(results.first['objects'].first['name']).to eq '水痘'
      expect(results.first['objects'].first['type']).to eq 'HealthCondition'
    end
  end

  context "Symptom" do
    let!(:symptom1) { create :symptom, name: 'Measles', category: 'Pediatrics' }
    let!(:symptom2) { create :symptom, name: 'Chicken pox', category: 'Pediatrics' }
    let!(:symptom3) { create :symptom, name: 'Preterm birth', category: 'Gynecology' }
    let!(:symptom4) { create :symptom, name: 'Infertility', category: 'Gynecology' }

    before do
      switch_locale 'zh-CN' do
        symptom1.name = '麻疹'
        symptom1.category = '儿科'
        symptom1.save
        symptom2.name = '水痘'
        symptom2.category = '儿科'
        symptom2.save
        symptom3.name = '早产'
        symptom3.category = '妇科'
        symptom3.save
        symptom4.name = '不孕症'
        symptom4.category = '妇科'
        symptom4.save
      end
    end

    it 'searches in English' do
      post '/v2/search?locale=en-US', { query: { text: 'Infertility' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 1
      expect(results.first['name']).to eq 'Gynecology'
      expect(results.first['objects'].first['name']).to eq 'Infertility'
      expect(results.first['objects'].first['type']).to eq 'Symptom'
    end

    it 'searches in Chinese' do
      post '/v2/search?locale=zh-CN', { query: { text: '水痘' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 1
      expect(results.first['name']).to eq '儿科'
      expect(results.first['objects'].first['name']).to eq '水痘'
      expect(results.first['objects'].first['type']).to eq 'Symptom'
    end
  end

  context "Speciality" do
    let!(:physician1) { create :physician, name: 'Zhang San' }
    let!(:physician2) { create :physician, name: 'Li Si' }
    let!(:speciality1) { create :speciality, name: 'Pediatrics' }
    let!(:speciality2) { create :speciality, name: 'Gynecology' }
    before do
      switch_locale 'zh-CN' do
        physician1.name = '张三'
        physician1.save
        physician2.name = '李四'
        physician2.save
        speciality1.name = '儿科'
        speciality1.save
        speciality2.name = '妇科'
        speciality2.save
      end

      create :physicians_speciality, physician: physician1, speciality: speciality1
      create :physicians_speciality, physician: physician1, speciality: speciality2
      create :physicians_speciality, physician: physician2, speciality: speciality2
    end

    it 'gets specialities' do
      post '/v2/search', { query: { type: 'Speciality' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 2
      expect(results.map { |p| p['id']}).to match_array [speciality1.id, speciality2.id]
      expect(results.map { |p| p['name']}).to match_array [speciality1.name, speciality2.name]
      expect(results.map { |p| p['physicians_count']}).to match_array [speciality1.physicians.size, speciality2.physicians.size]
    end

    it 'searches in English' do
      post '/v2/search?locale=en-US', { query: { type: 'Speciality', text: 'Pediatrics' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 1
      expect(results.first['name']).to eq 'Pediatrics'
    end

    it 'searches in Chinese' do
      post '/v2/search?locale=zh-CN', { query: { type: 'Speciality', text: '儿科' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 1
      expect(results.first['name']).to eq '儿科'
    end
  end

  context "Department" do
    let!(:hospital1) { create(:hospital, name: 'Shanghai Hospital', latitude: "31.2123", longitude: "121.5123", h_class: '二级乙等') }
    let!(:hospital2) { create(:hospital, name: 'New Delhi Hospital', latitude: "28.6139", longitude: "77.2089", h_class: '三级甲等') }
    let!(:department1) { create :department, name: 'Pediatrics' }
    let!(:department2) { create :department, name: 'Gynecology' }
    before do
      switch_locale 'zh-CN' do
        hospital1.name = '上海医院'
        hospital1.save
        hospital2.name = '新德里医院'
        hospital2.save
        department1.name = '儿科'
        department1.save
        department2.name = '妇科'
        department2.save
      end

      create :departments_hospital, hospital: hospital1, department: department1
      create :physician, hospital: hospital1, department: department1
      create :departments_hospital, hospital: hospital2, department: department2
      create :physician, hospital: hospital2, department: department2

      create :department
    end

    it 'gets hospital\'s departments' do
      post '/v2/search', { query: { hospital_id: hospital2.id, type: 'Department' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 1
      expect(results.first['id']).to eq department2.id
      expect(results.first['physicians_count'] ).to eq 1
    end

    it 'gets departments, nearby 上海医院' do
      post '/v2/search', { query: { type: 'Department', nearby: { lat: 31.2122, lng: 121.5122, distance: 1.0 } } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 1
      expect(results.first['id']).to eq department1.id
    end

    it 'searchs in English' do
      post '/v2/search?locale=en-US', { query: { type: 'Department', text: 'Pediatrics' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 1
      expect(results.first['name']).to eq 'Pediatrics'
    end

    it 'searchs in Chinese' do
      post '/v2/search?locale=zh-CN', { query: { type: 'Department', text: '儿科' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 1
      expect(results.first['name']).to eq '儿科'
    end
  end

  describe 'Review' do
    let(:hospital) { create :hospital }
    let(:physician) { create :physician }
    let(:medication) { create :medication }
    let!(:hospital_reviews) do
      reviews = []
      travel(-1.day) { reviews = create_list :hospital_review, 2, hospital: hospital, status: 'published', note: 'note 1' }
      reviews
    end
    let!(:physician_reviews) do
      reviews = []
      travel(-3.days) { reviews = create_list :physician_review, 2, physician: physician, status: 'published', note: 'note 123' }
      reviews
    end
    let!(:medication_reviews) do
      reviews = []
      travel(-2.days) { reviews = create_list :medication_review, 2, medication: medication, status: 'published', note: 'note 12' }
      reviews
    end

    it 'gets reviews by hospital' do
      post '/v2/search', { query: { type: 'HospitalReview' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.map { |r| r['id'] }).to match_array hospital_reviews.map(&:id)
    end

    it 'gets reviews by physician' do
      post '/v2/search', { query: { type: 'PhysicianReview' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.map { |r| r['id'] }).to match_array physician_reviews.map(&:id)
    end

    it 'gets reviews by medication' do
      post '/v2/search', { query: { type: 'MedicationReview' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.map { |r| r['id'] }).to match_array medication_reviews.map(&:id)
    end

    it 'gets reviews sorting by distance, no error raised for distance' do
      post '/v2/search', { query: { type: 'HospitalReview,PhysicianReview,MedicationReview' }, sort: { distance: { lat: 31.2, lng: 121.5 } } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 6
    end

    it 'gets reviews sorting by created_at' do
      post '/v2/search', { query: { type: 'HospitalReview,PhysicianReview,MedicationReview' }, sort: { created_at: true } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.map { |r| r['id'] }[0..1]).to match_array hospital_reviews.map(&:id)
      expect(results.map { |r| r['id'] }[2..3]).to match_array medication_reviews.map(&:id)
      expect(results.map { |r| r['id'] }[4..5]).to match_array physician_reviews.map(&:id)
    end

    it 'gets reviews sorting by content_length' do
      post '/v2/search', { query: { type: 'HospitalReview,PhysicianReview,MedicationReview' }, sort: { content_length: true } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.map { |r| r['id'] }[0..1]).to match_array physician_reviews.map(&:id)
      expect(results.map { |r| r['id'] }[2..3]).to match_array medication_reviews.map(&:id)
      expect(results.map { |r| r['id'] }[4..5]).to match_array hospital_reviews.map(&:id)
    end
  end

  describe 'HospitalReview' do
    let!(:hospital) { create :hospital }
    let!(:hospital_reviews) { create_list :hospital_review, 2, status: 'published', hospital: hospital }
    let!(:review) { create :hospital_review, status: 'published' }

    it 'gets reviews by hospital id' do
      post '/v2/search', { query: { type: 'HospitalReview', hospital_id: hospital.id } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.map { |r| r['id'] }).to match_array hospital_reviews.map(&:id)
    end
  end

  describe 'PhysicianReview' do
    let!(:physician) { create :physician }
    let!(:physician_reviews) { create_list :physician_review, 2, status: 'published', physician: physician }
    let!(:review) { create :physician_review, status: 'published' }

    it 'gets reviews by physician id' do
      post '/v2/search', { query: { type: 'PhysicianReview', physician_id: physician.id } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.map { |r| r['id'] }).to match_array physician_reviews.map(&:id)
    end
  end

  describe 'MedicationReview' do
    let!(:medication) { create :medication }
    let!(:medication_reviews) { create_list :medication_review, 2, status: 'published', medication: medication }
    let!(:review) { create :medication_review, status: 'published' }

    it 'gets reviews by medication id' do
      post '/v2/search', { query: { type: 'MedicationReview', medication_id: medication.id } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.map { |r| r['id'] }).to match_array medication_reviews.map(&:id)
    end
  end

  describe 'Review by user_id' do
    let!(:user1) { create :user }
    let!(:user2) { create :user }
    let!(:medical_experience1) { create :medical_experience, user: user1 }
    let!(:medical_experience2) { create :medical_experience, user: user2 }

    let!(:hospital) { create :hospital }
    let!(:physician) { create :physician }
    let!(:medication) { create :medication }
    let!(:hospital_review1) { create :hospital_review, status: 'published', hospital: hospital, medical_experience: medical_experience1 }
    let!(:hospital_review2) { create :hospital_review, status: 'published', hospital: hospital, medical_experience: medical_experience2 }
    let!(:physician_review1) { create :physician_review, status: 'published', physician: physician, medical_experience: medical_experience1 }
    let!(:physician_review2) { create :physician_review, status: 'published', physician: physician, medical_experience: medical_experience2 }
    let!(:medication_review1) { create :medication_review, status: 'published', medication: medication, medical_experience: medical_experience1 }
    let!(:medication_review2) { create :medication_review, status: 'published', medication: medication, medical_experience: medical_experience2 }

    it 'searches hospital reviews by user1' do
      post '/v2/search', { query: { type: 'HospitalReview', user_id: user1.id } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 1
      expect(results.first['id']).to eq hospital_review1.id
    end

    it 'searches physician reviews by user1' do
      post '/v2/search', { query: { type: 'PhysicianReview', user_id: user1.id } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 1
      expect(results.first['id']).to eq physician_review1.id
    end

    it 'searches medication reviews by user1' do
      post '/v2/search', { query: { type: 'MedicationReview', user_id: user1.id } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 1
      expect(results.first['id']).to eq medication_review1.id
    end
  end

  describe 'filter by type' do
    let(:hospital1) { create(:hospital, name: '上海医院', latitude: "31.2123", longitude: "121.5123", avg_rating: '3.5') }
    let(:hospital2) { create(:hospital, name: 'New Delhi hospital', latitude: "28.6139", longitude: "77.2089", avg_rating: '4.5') }
    let(:department1) { create :department }
    let(:department2) { create :department }
    let(:physician1) { create :physician, hospital: hospital1, department: department1, name: 'in department 123', avg_rating: 3.5 }
    let(:physician2) { create :physician, hospital: hospital1, department: department1, name: 'cross hospitals', avg_rating: 4.0 }
    let(:physician3) { create :physician, hospital: hospital2, department: department2, name: 'in department 321', avg_rating: 4.5 }
    let(:speciality1) { create :speciality }
    let(:speciality2) { create :speciality }
    before do
      create :departments_hospital, hospital: hospital1, department: department1
      create :departments_hospital, hospital: hospital2, department: department2
      create :physicians_speciality, physician: physician1, speciality: speciality1
      create :physicians_speciality, physician: physician2, speciality: speciality2
      create :physicians_speciality, physician: physician3, speciality: speciality1
    end

    it 'searches all by hospital' do
      post '/v2/search', { query: { hospital_id: hospital1.id } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 4
      expect(results.map { |p| p['id'] }).to match_array [hospital1.id, physician1.id, physician2.id, department1.id]
      expect(results.map { |p| p['class_name'] }).to match_array ['Hospital', 'Physician', 'Physician', 'Department']
    end

    it 'searches departments by hospital' do
      post '/v2/search', { query: { hospital_id: hospital1.id, type: 'Department' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 1
      expect(results.first['id']).to eq department1.id
      expect(results.first['class_name']).to eq 'Department'
    end

    it 'searches physicians by hospital' do
      post '/v2/search', { query: { hospital_id: hospital1.id, type: 'Physician' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 2
      expect(results.map { |p| p['id'] }).to match_array [physician1.id, physician2.id]
      expect(results.map { |p| p['class_name'] }).to match_array ['Physician', 'Physician']
    end

    it 'searches departments and physicians by hospital' do
      post '/v2/search', { query: { hospital_id: hospital1.id, type: 'Department, Physician' } }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      results = parsed_body['results']
      expect(results.length).to eq 3
      expect(results.map { |p| p['id'] }).to match_array [physician1.id, physician2.id, department1.id]
      expect(results.map { |p| p['class_name'] }).to match_array ['Physician', 'Physician', 'Department']
    end
  end

  describe 'filter by pagination' do
    let!(:hospital1) { create(:hospital, name: '上海医院', latitude: "31.2123", longitude: "121.5123", avg_rating: '3.5') }
    let!(:hospital2) { create(:hospital, name: 'New Delhi hospital', latitude: "28.6139", longitude: "77.2089", avg_rating: '4.5') }
    let!(:hospital3) { create(:hospital, name: '新上海医院', latitude: "31.2223", longitude: "120.5123", avg_rating: '4.5') }

    it 'searches for page 1' do
      post '/v2/search', { query: { type: 'Hospital' }, per_page: 2 }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['total_pages']).to eq 2
      expect(parsed_body['total_count']).to eq 3
      expect(parsed_body['results'].length).to eq 2
    end

    it 'searches for page 2' do
      post '/v2/search', { query: { type: 'Hospital' }, per_page: 2, page: 2 }
      expect(response.status).to eq 200
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['total_pages']).to eq 2
      expect(parsed_body['total_count']).to eq 3
      expect(parsed_body['results'].length).to eq 1
    end
  end
end
