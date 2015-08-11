Given /^all data are prepared$/ do
  user = create(:user, email: 'test@thecarevoice.com', password: '123456', phone: '12345678901')

  hospital1 = create(:hospital, name: 'Shanghai Hospital', latitude: "31.2123", longitude: "121.5123", avg_rating: '3.5')
  hospital2 = create(:hospital, name: 'New Delhi Hospital', latitude: "28.6139", longitude: "77.2089", avg_rating: '4.5')
  create(:hospital, name: 'Shanghai Ruijing Hospital', latitude: "31.2124", longitude: "121.5124", avg_rating: '4.5')

  department1 = create :department
  department2 = create :department
  speciality1 = create :speciality
  speciality2 = create :speciality

  create :departments_hospital, hospital: hospital1, department: department1
  create :departments_hospital, hospital: hospital2, department: department2
  physician1 = create :physician, hospital: hospital1, department: department1, name: 'test 123', avg_rating: 3.5
  physician2 = create :physician, hospital: hospital1, department: department1, name: 'tset 123', avg_rating: 4.0
  physician3 = create :physician, hospital: hospital2, department: department2, name: 'test 321', avg_rating: 4.5
  create :physicians_speciality, physician: physician1, speciality: speciality1
  create :physicians_speciality, physician: physician2, speciality: speciality2
  create :physicians_speciality, physician: physician3, speciality: speciality1

  create :medication, name: 'test 123', code: 'tset 123'
  create :medication, name: 'tset 123', code: 'test 123'
  create :medication, name: '123', code: '123'
end

When(/^I send a POST "(.*?)" review request to "(.*?)" for name "(.*?)" and the following:$/) do |type, path, name, input|
  klazz = type.classify.constantize
  reviewable = klazz.find_by(name: name)

  request_opts = {method: :post}
  review_input = JSON.parse(input)
  review_input['review']['reviewable_id'] = reviewable.id
  request_opts[:input] = JSON.generate review_input

  request path, request_opts
end

When(/^I send a GET "(.*?)" review request to "(.*?)" for review note "(.*?)"$/) do |type, path, review_note|
  klazz = "#{type}_review".classify.constantize
  review = klazz.find_by note: review_note

  path.sub! ':id', review.id.to_s
  request_opts = {method: :get}

  request path, request_opts
end
