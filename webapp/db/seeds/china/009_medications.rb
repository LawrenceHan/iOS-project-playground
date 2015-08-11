puts "Transfer medications from cegedim table ..."
Cegedim::Medication.find_each(batch_size: 1000) do |c|
  medication = Medication.where(vendor_id: c.uid).first_or_initialize
  medication.assign_attributes(
    name: c.cn_name.presence || c.en_name.presence,
    code: c.code,
    old_companies: c.old_companies,
    dosage1: c.dosage1,
    dosage2: c.dosage2,
    dosage3: c.dosage3
  )
  medication.save! if medication.new_record? or medication.changed?
  printf '.'
end

puts ''

puts 'Link master to local medications ...'
Cegedim::Medication.where.not(master_uid: nil).find_each(batch_size: 1000) do |c|
  if local = Medication.find_by(vendor_id: c.uid)
    master = Medication.find_by(vendor_id: c.master_uid)
    local.master_id = master.try(:id)
    local.save! if local.changed?
    printf '.'
  end
end

puts ''
