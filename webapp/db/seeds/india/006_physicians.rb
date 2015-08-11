require 'roo'

  puts "Clean up physicians, specialities and  physicians specialities"
  Speciality.destroy_all
  PhysiciansSpeciality.destroy_all
  Physician.destroy_all

# if Speciality.count < 10
  file_path = Rails.root.join('tmp', 'india', 'physicians.xlsx').to_s
  s = Roo::Excelx.new(file_path)

  puts "Import specialities "
  s.default_sheet = s.sheets.first
  (2..s.last_row).each do |i|
    data = s.row(i)
    vendor_id = data[0].to_i
    name = data[1].to_s.strip

    Speciality.where(vendor_id: vendor_id).first_or_create(name: name)
    printf '.'
  end
# end

# if Physician.count < 100
  puts "Import physicians "
  s.default_sheet = s.sheets[1]
  (2..s.last_row).each do |i|
    data = s.row(i)
    vendor_id = data[0].to_i.to_s
    name = data[1].to_s.strip
    gender = data[2].to_s.strip.downcase
    hospital_vendor_id = data[3].to_i.to_s
    department_vendor_id = data[4].to_i.to_s
    first_speciality_vendor_id = data[5].to_i
    second_speciality_vendor_id = data[7].to_i
    third_speciality_vendor_id = data[9].to_i

    physician = Physician.where(vendor_id: vendor_id).first_or_initialize(name: name, gender: gender)

    if hospital = Hospital.find_by(vendor_id: hospital_vendor_id)
      physician.hospital_id = hospital.id
    end

    if department = Department.find_by(vendor_id: department_vendor_id)
      physician.department_id = department.id
    end


    physician.first_speciality = Speciality.find_by(vendor_id: first_speciality_vendor_id)
    physician.second_speciality = Speciality.find_by(vendor_id: second_speciality_vendor_id)
    physician.third_speciality = Speciality.find_by(vendor_id: third_speciality_vendor_id)

    (physician.new_record? || physician.changed?) && physician.save && printf('.')

    printf '.'
  end
# end
puts ''
