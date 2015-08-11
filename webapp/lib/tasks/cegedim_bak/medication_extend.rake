require 'roo'

namespace :medication_bak do
  desc 'Import IBN ID for each medications'
  task :ibn_id => :environment do
    master_file_path = Rails.root.join('tmp', 'cegedim', 'medication', 'medications.master.xlsx').to_s
    local_file_path = Rails.root.join('tmp', 'cegedim', 'medication', 'medications.local.xlsx').to_s
    s = Roo::Excelx.new(master_file_path)
    puts 'Import ibn_id for master'
    s.default_sheet = s.sheets.first
    (2..s.last_row).each do |i|
      data = s.row(i)
      vendor_id = data[0].to_i
      ibn_id = data[1].to_i

      if medication = Medication.find_by(vendor_id: vendor_id)
        medication.ibn_id = ibn_id
        medication.changed? && medication.save && printf('.')
      else
        puts "Can't find drug with vendor_id: #{vendor_id}"
      end
    end
  end



  desc 'Import IBN name for each medications'
  task :ibn_and_eph => :environment do
    file_path = Rails.root.join('tmp', 'cegedim', 'medication', 'medications.ibn.xlsx').to_s
    s = Roo::Excelx.new(file_path)
    puts ''
    puts 'Import ibn_name, ibn_code and eph_id'
    s.default_sheet = s.sheets.first
    (2..s.last_row).each do |i|
      data = s.row(i)
      ibn_id = data[0].to_i
      ibn_code = data[2].to_s.strip
      ibn_name = data[3].to_s.strip
      eph_id = data[4].to_i

      if medication = Medication.find_by(ibn_id: ibn_id)
        medication.ibn_code = ibn_code
        medication.ibn_name = ibn_name
        medication.eph_id = eph_id
        medication.changed? && medication.save && printf('.')
      # else
      #   puts "Can't find drug with ibn_id: #{ibn_id}"
      end
    end

    puts ''
    puts 'Import eph_name'
    s.default_sheet = s.sheets[1]
    (2..s.last_row).each do |i|
      data = s.row(i)
      eph_id = data[0].to_i
      eph_name = data[2].to_s.strip

      if medication = Medication.find_by(eph_id: eph_id)
        medication.eph_name = eph_name
        medication.changed? && medication.save && printf('.')
      # else
      #   puts "Can't find drug with eph_id: #{eph_id}"
      end
    end

    puts ''
    puts 'Copy infos from master to local'
    Medication.locals.each do |local|
      if master = local.master
        local.assign_attributes(
          ibn_id: master.ibn_id,
          ibn_name: master.ibn_name,
          ibn_code: master.ibn_code,
          eph_id: master.eph_id,
          eph_name: master.eph_name
        )
        local.changed? && local.save && printf('.')
      end
    end
  end

  task :extend => [:ibn_id, :ibn_and_eph]
end
