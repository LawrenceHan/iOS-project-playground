require 'roo'
puts "Import hospital reviews "

if true
  file_path = Rails.root.join('tmp', 'india', 'hospital_review', 'hospital_reviews.20140509.xlsx').to_s
  s = Roo::Excelx.new(file_path)
  s.default_sheet = s.sheets.first
  (2..s.last_row).each do |i|
    data = s.row(i)
    first_name = data[0].to_s.strip
    last_name = data[1].to_s.strip
    name = [first_name, last_name].compact.join(' ')
    birthdate = data[2].to_date
    gender = data[3].to_s.strip.downcase

    email = data[4].to_s.strip
    phone = data[5].to_i.to_s.strip

    hospital_vendor_id = data[6].to_i.to_s

    q_1 = Question.hospital_questions.find_by(content: 'Convenient location')
    q_1_value = data[8].to_i

    q_2 = Question.hospital_questions.find_by(content: 'Cleanliness')
    q_2_value = data[9].to_i

    q_3 = Question.hospital_questions.find_by(content: 'Modern facilities')
    q_3_value = data[10].to_i

    q_4 = Question.hospital_questions.find_by(content: 'Comfort level')
    q_4_value = data[11].to_i

    q_5 = Question.hospital_questions.find_by(content: 'Waiting time')
    q_5_value = data[12].to_i

    q_6 = Question.hospital_questions.find_by(content: 'Appointment making service')
    q_6_value = data[13].to_i

    q_7 = Question.hospital_questions.find_by(content: 'Range of medical services')
    q_7_value = data[14].to_i

    q_8 = Question.hospital_questions.find_by(content: 'Attentiveness and politeness')
    q_8_value = data[15].to_i

    note = data[16].to_s.strip

    if hospital = Hospital.find_by(vendor_id: hospital_vendor_id)
      user = User.find_by(phone: phone) || User.find_by(email: email) || User.new(phone: phone, email: email)
      if user.new_record?
        user.password = "#{first_name}#{phone}"
        user.confirm
        user.save!(validate: false)
        user.send_email_as_survey_user
        user.reload

        user.profile.update(
          username: name,
          gender: gender,
          birthdate: birthdate
        )
      end


      m = user.medical_experiences.first_or_create

      hospital_review = HospitalReview.where(medical_experience_id: m.id, reviewable_id: hospital.id ).first_or_initialize
      hospital_review.assign_attributes({
        note: note,
        answers_attributes: [
          {question_id: q_1.id, rating: q_1_value},
          {question_id: q_2.id, rating: q_2_value},
          {question_id: q_3.id, rating: q_3_value},
          {question_id: q_4.id, rating: q_4_value},
          {question_id: q_5.id, waiting_time: q_5_value},
          {question_id: q_6.id, rating: q_6_value},
          {question_id: q_7.id, rating: q_7_value},
          {question_id: q_8.id, rating: q_8_value},
        ]
      })

      (hospital_review.new_record? || hospital_review.changed?) && hospital_review.save && printf('.')
    else
      puts ''
      puts "Hospital not found with vendor_id: #{hospital_vendor_id}"
    end
  end
end
puts ''
