require 'roo'
puts "Import medications "

if Medication.count < 100
  file_path = Rails.root.join('tmp', 'india', 'medications.xlsx').to_s
  s = Roo::Excelx.new(file_path)
  s.default_sheet = s.sheets.first
  (2..s.last_row).each do |i|
    data = s.row(i)
    vendor_id = data[0].to_i
    name = data[1].to_s.strip
    en_name = data[3].to_s.strip
    if name.present?
      medication = Medication.where(name: name).first_or_initialize
      medication.vendor_id = vendor_id
      (medication.new_record? || medication.changed?) && medication.save
      if en_name.present?
        company = Company.where(en_name: en_name).first_or_create
        CompaniesMedication.where(company_id: company.id, medication_id: medication.id).first_or_create(begin_at: Date.today, end_at: Date.today)
      end
      printf '.'
    end
  end
  puts ''
end

puts ''
