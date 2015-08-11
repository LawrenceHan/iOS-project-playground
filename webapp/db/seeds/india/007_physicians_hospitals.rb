# require 'roo'
# puts 'Import extra hospitals '

# extra_path = Rails.root.join('tmp', 'india', 'physicians_hospitals.xlsx').to_s
# s = Roo::Excelx.new(extra_path)
# s.default_sheet = s.sheets[1]
# (2..s.last_row).each do |i|
#   data = s.row(i)
#   vendor_id = data[0].to_i.to_s
#   name = data[1].to_s.strip
#   address = data[2].to_s.strip
#   Hospital.where(vendor_id: vendor_id).first_or_create(address: address, name: name)
#   printf '.'
# end
# puts ''

# puts 'Import extra physicians '
# s.default_sheet = s.sheets.first
# (2..s.last_row).each do |i|
#   data = s.row(i)
#   vendor_id = data[0].to_i.to_s
#   speciality_names = data[1].to_s.split(',').map(&:strip)
#   name = data[2].to_s.strip
#   hospital_vendor_id = data[3].to_i.to_s
#   gender = data[12].to_s.downcase
#   position = data[13].to_s.strip
#   if name.present?
#     physician = Physician.where(vendor_id: vendor_id).first_or_initialize(name: name, position: position, gender: gender)
#     if hospital = Hospital.find_by(vendor_id: hospital_vendor_id)
#       physician.hospital_id = hospital.id
#     end
#     (physician.new_record? || physician.changed?) && physician.save
#     if speciality_names.present?
#       speciality_names.each_with_index do |speciality_name, index|
#         speciality = Speciality.where(name: speciality_name).first_or_create
#         PhysiciansSpeciality.where(physician_id: physician.id, speciality_id: speciality.id).first_or_create(priority: index + 1)
#       end
#     end
#   end
#   printf '.'
# end
# puts ''
