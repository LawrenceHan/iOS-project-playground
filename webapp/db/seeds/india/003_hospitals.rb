require 'roo'

# if Department.count < 10
  file_path = Rails.root.join('tmp', 'india', 'hospitals.xlsx').to_s
  s = Roo::Excelx.new(file_path)

  puts "Import departments "
  s.default_sheet = s.sheets.first
  (2..s.last_row).each do |i|
    data = s.row(i)
    vendor_id = data[0].to_i.to_s
    name = data[1].to_s.strip

    department = Department.where(vendor_id: vendor_id).first_or_initialize
    department.name = name
    (department.new_record? || department.changed?) && department.save && printf('.')
  end
# end

# if Hospital.count < 100
  puts "Import hospitals "
  s.default_sheet = s.sheets[1]
  (2..s.last_row).each do |i|
    data = s.row(i)
    vendor_id = data[0].to_i.to_s
    name = data[1].to_s.strip
    address = data[2].to_s.strip
    department_ids = data[3].to_s.split(/\s*,\s*/).delete_if(&:blank?).map{|x| x.to_i.to_s}

    if hospital = Hospital.where(vendor_id: vendor_id).first_or_initialize
      hospital.name = name
      hospital.address = address
      (hospital.new_record? || hospital.changed?) && hospital.save && printf('.')

      if department_ids.present?
        department_ids.each do |d_id|
          Department.exists?(id: d_id) && DepartmentsHospital.where(hospital_id: hospital.id, department_id: d_id).first_or_create && printf('.')
        end
      end
    end
  end
# end
puts ''


