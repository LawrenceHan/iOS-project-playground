puts "Transfer hospitals from cegedim table ..."
Cegedim::Hospital.find_each(batch_size: 1000) do |c|
  h = Hospital.where(vendor_id: c.uid).first_or_initialize
  h.assign_attributes(
    name: c.name,
    official_name: c.official_name,
    phone: c.phone,
    address: c.address,
    post_code: c.post_code,
    h_class: c.h_class,
    city: c.city
  )
  h.save! if h.new_record? or h.changed?
  printf '.'
end

puts ''

# Import parent hospitals
puts 'Assign parent hospital to sub hospital ...'
Cegedim::Hospital.where.not(parent_uid: nil).find_each(batch_size: 1000) do |c|
  if sub_hospital = Hospital.find_by(vendor_id: c.uid)
    parent_hospital = Hospital.find_by(vendor_id: c.parent_uid)
    sub_hospital.parent_id = parent_hospital.id
    sub_hospital.save! if sub_hospital.changed?
    printf '.'
  end
end

puts ''

puts "Transfer departments from cegedim table ..."
Cegedim::Department.find_each(batch_size: 1000) do |c|
  d = Department.where(vendor_id: c.uid).first_or_initialize
  d.assign_attributes(name: c.name)
  d.save! if d.new_record? or d.changed?
  printf '.'
end

puts ''


puts "Transfer departments from cegedim table ..."
Cegedim::Department.find_each(batch_size: 1000) do |c|
  d = Department.where(vendor_id: c.uid).first_or_initialize
  h = Hospital.find_by(vendor_id: c.hospital_uid)
  if d && h
    DepartmentsHospital.create(:department_id => d.id, :hospital_id => h.id)
    printf '.'
  else
    printf 'x'
  end
end

puts ''
