puts 'Import companies to cegedim_companies table ...'
# cegedim companies data are imported in db/seeds/china/007_cegedim.rb for development env
Rake::Task['cegedim_bak:company:import'].invoke unless Rails.env.development?

puts 'Copy cegedim_companies to companies table ...'
Cegedim::Company.find_each(batch_size: 1000) do |c|
  company = Company.where(vendor_id: c.uid).first_or_initialize
  company.assign_attributes(
    en_name: c.en_name,
    cn_name: c.cn_name
  )
  company.save! if company.new_record? or company.changed?
  printf '.'
end

puts ''

puts 'Copy cegedim_companies_medications to companies_medications table ...'
Cegedim::CompaniesMedication.find_each(batch_size: 1000) do |c|
  company = Company.find_by(vendor_id: c.company_uid)
  medication = Medication.find_by(vendor_id: c.medication_uid)
  if company && medication
    join = CompaniesMedication.where(company_id: company.id, medication_id: medication.id).first_or_initialize
    join.assign_attributes(
      begin_at: c.begin_at,
      end_at: c.end_at
    )
    join.save! if join.new_record? or join.changed?
    printf '.'
  end
end
