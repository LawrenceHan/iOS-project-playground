require 'roo'
puts "Import medication reviews "

if true
  file_path = Rails.root.join('tmp', 'india', 'medication_review', 'medication_reviews.first.xlsx').to_s
  s = Roo::Excelx.new(file_path)
  s.default_sheet = s.sheets.first
  (2..s.last_row).each do |i|
    data = s.row(i)
    first_name = data[0].to_s.strip
    last_name = data[1].to_s.strip
    name = [first_name, last_name].compact.join(' ')
    birthdate = (data[2].to_date rescue nil)
    gender = data[3].to_s.strip.downcase

    email = data[4].to_s.strip
    phone = data[5].to_i.to_s.strip

    medication_vendor_id = data[6].to_i
    dosage = "#{data[8].to_i.to_s} mg"

    adverse_effects = data[12].to_s.strip
    duration = data[14].to_s.strip

    q_1 = Question.medication_questions.find_by(content: 'Effectiveness')
    q_1_value = data[9].to_i

    q_2 = Question.medication_questions.find_by(content: 'Ease of use')
    q_2_value = data[10].to_i

    q_3 = Question.medication_questions.find_by(content: 'Tolerance')
    q_3_value = data[11].to_i

    q_4 = Question.medication_questions.find_by(content: 'Price')
    q_4_value = data[13].to_i

    note = data[15].to_s.strip

    if medication = Medication.find_by(vendor_id: medication_vendor_id)
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

      medication_review = MedicationReview.where(medical_experience_id: m.id, reviewable_id: medication.id ).first_or_initialize
      medication_review.assign_attributes({
        dosage: dosage,
        duration: duration,
        adverse_effects: adverse_effects,
        note: note,
        answers_attributes: [
          {question_id: q_1.id, rating: q_1_value},
          {question_id: q_2.id, rating: q_2_value},
          {question_id: q_3.id, rating: q_3_value},
          {question_id: q_4.id, rating: q_4_value}
        ]
      })

      (medication_review.new_record? || medication_review.changed?) && medication_review.save && printf('.')
    else
      puts ''
      puts "Hospital not found with vendor_id: #{medication_vendor_id}"
    end
  end
end
puts ''
