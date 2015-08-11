require 'roo'

namespace :import do
  namespace :medication do
    task :all => [:environment, :master, :local, :company, :ibn, :eph]

    desc 'Import master medications'
    task :master do
      puts ''
      puts 'Import master medications'
      s = drug_file_data
      s.default_sheet = s.sheets[1]
      (2..s.last_row).each do |i|
        data = s.row(i)
        vendor_id = data[0].to_i
        ibn_id = data[1].to_i
        code = data[2].to_s.strip.presence
        en_name = data[3].to_s.strip
        cn_name = data[4].to_s.strip
        name = cn_name.presence || en_name

        medication = Medication.where(vendor_id: vendor_id).first_or_initialize
        medication.assign_attributes(ibn_id: ibn_id, code: code, name: name)
        (medication.new_record? || medication.changed?) && medication.save && printf('.')
      end
    end

    desc 'Import local medications'
    task :local do
      puts ''
      puts 'Import local medications'
      s = drug_file_data
      s.default_sheet = s.sheets.first
      (2..s.last_row).each do |i|
        data = s.row(i)
        master_vendor_id = data[0].to_i
        vendor_id = data[1].to_i
        en_name = data[2].to_s.strip
        cn_name = data[3].to_s.strip
        name = cn_name.presence || en_name
        otc = (data[6].present? ? data[6].to_i : nil)
        dosage1 = data[7].to_s.strip.presence
        dosage2 = data[8].to_s.strip.presence
        dosage3 = data[9].to_s.strip.presence

        master = Medication.find_by(vendor_id: master_vendor_id)
        medication = Medication.where(vendor_id: vendor_id).first_or_initialize
        medication.assign_attributes(name: name, otc: otc, dosage1: dosage1, dosage2: dosage2, dosage3: dosage3, code: master.try(:code), ibn_id: master.try(:ibn_id), master_id: master.try(:id))
        (medication.new_record? || medication.changed?) && medication.save && printf('.')
      end
    end

    desc 'Import companies for medication'
    task :company do
      puts ''
      puts 'Import companie'
      s = drug_file_data
      s.default_sheet = s.sheets[4]
      (2..s.last_row).each do |i|
        data = s.row(i)
        vendor_id = data[0].to_i
        en_name = data[2].to_s.strip.presence
        cn_name = data[3].to_s.strip.presence
        Company.where(vendor_id: vendor_id).first_or_create(en_name: en_name, cn_name: cn_name)
        printf('.')
      end

      puts ''
      puts 'Import companies for medication'
      s = drug_file_data
      s.default_sheet = s.sheets[5]
      (2..s.last_row).each do |i|
        data = s.row(i)
        company_vendor_id = data[0].to_i
        master_vendor_id = data[1].to_i
        begin_at = data[2]
        end_at = data[3]

        company = Company.find_by(vendor_id: company_vendor_id)
        master = Medication.find_by(vendor_id: master_vendor_id)

        if company && master
          CompaniesMedication.where(company_id: company.id, medication_id: master.id).first_or_create(begin_at: begin_at, end_at: end_at)
          printf('.')

          # Import companies for local as well
          master.local.each do |local|
            CompaniesMedication.where(company_id: company.id, medication_id: local.id).first_or_create(begin_at: begin_at, end_at: end_at)
            printf('.')
          end
        end
      end
    end

    desc 'Import IBN for medication'
    task :ibn do
      puts ''
      puts 'Import IBN for medication'
      s = drug_file_data
      s.default_sheet = s.sheets[2]
      (2..s.last_row).each do |i|
        data = s.row(i)
        ibn_id = data[0].to_i
        ibn_code = data[2].to_s.strip.presence
        ibn_name = data[3].to_s.strip.presence
        eph_id = data[4].to_i

        Medication.where(ibn_id: ibn_id).each do |medication|
          medication.assign_attributes(ibn_code: ibn_code, ibn_name: ibn_name, eph_id: eph_id)
          medication.changed? && medication.save && printf('.')
        end
      end
    end

    desc 'Import EPH for medication'
    task :eph do
      puts ''
      puts 'Import EPH for medication'
      s = drug_file_data
      s.default_sheet = s.sheets[3]
      (2..s.last_row).each do |i|
        data = s.row(i)
        eph_id = data[0].to_i
        eph_name = data[2].to_s.strip.presence

        Medication.where(eph_id: eph_id).each do |medication|
          medication.assign_attributes(eph_name: eph_name)
          medication.changed? && medication.save && printf('.')
        end
      end
    end

    def drug_file_data
      @drug_file_data ||= Roo::Excelx.new(Rails.root.join('tmp', 'cegedim', 'medication', 'medication.xlsx').to_s)
    end
  end
end
