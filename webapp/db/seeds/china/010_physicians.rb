puts "Transfer physicians from cegedim table ..."
Cegedim::Physician.find_each(batch_size: 1000) do |c|
  physician = Physician.where(vendor_id: c.uid).first_or_initialize
  hospital = Hospital.find_by(vendor_id: c.hospital_uid)
  department = Department.find_by(vendor_id: c.department_uid)
  physician.assign_attributes(
    hospital_id: hospital.try(:id),
    department_id: department.try(:id),
    name: c.name,
    position: c.position,
    birthdate: c.birthdate,
    gender: c.gender
  )
  physician.save! if physician.new_record? or physician.changed?
  printf '.'
end

puts ''

puts 'Transfer specialities from cegedim table ...'
Cegedim::Speciality.all.each do |c|
  speciality = Speciality.where(vendor_id: c.id).first_or_initialize
  speciality.assign_attributes(name: c.name)
  speciality.save! if speciality.new_record? or speciality.changed?
  printf '.'
end

puts ''

puts 'Link specialities and physicians ...'
Cegedim::PhysiciansSpeciality.all.each do |c|
  physician = Physician.find_by(vendor_id: c.physician_uid)
  speciality = Speciality.find_by(vendor_id: c.speciality_id)
  link = PhysiciansSpeciality.where(physician_id: physician.try(:id), speciality_id: speciality.try(:id)).first_or_initialize
  link.assign_attributes(priority: c.priority)
  link.save! if link.new_record? or link.changed?
  printf '.'
end

puts ''
