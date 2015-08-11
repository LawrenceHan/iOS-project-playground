require 'roo'

namespace :cegedim_bak do
  namespace :company do
    task :cn_name => :environment do
      puts 'Importing company chinese mame ...'
      puts 'Loading data file ...'
      file_path = Rails.root.join('tmp', 'cegedim', 'medication', 'cn_name.xlsx').to_s
      s = Roo::Excelx.new(file_path)
      s.default_sheet = s.sheets.first

      puts 'Calculating count ...'
      row_count = s.last_row
      puts "Begin to import #{row_count - 1} mames..."
      (2..row_count).each do |i|
        data = s.row(i)
        company = Cegedim::Company.find_by(uid: data[0].to_i)
        cn_name = (data[3] == 'NULL' ? nil : data[3])
        company && company.update(cn_name: cn_name)
        printf '.'
      end
      puts ''
    end

    task :init => :environment do
      puts 'Importing companies ...'
      puts 'Loading data file ...'
      file_path = Rails.root.join('tmp', 'cegedim', 'medication', 'medications.companies.xlsx').to_s
      s = Roo::Excelx.new(file_path)
      s.default_sheet = s.sheets.first

      puts 'Calculating master medications count ...'
      row_count = s.last_row
      puts "Begin to import #{row_count - 1} companies..."
      (2..row_count).each do |i|
        data = s.row(i)
        company = Cegedim::Company.where(uid: data[0].to_i).first_or_create(en_name: data[4])
        medication = Cegedim::Medication.where(uid: data[1].to_i).first
        company && medication && Cegedim::CompaniesMedication.where(company_uid: data[0].to_i, medication_uid: data[1].to_i).first_or_create(begin_at: data[2], end_at: data[3])
        printf '.'
      end

      puts ''
      puts 'Copy companies from master to local'
      Cegedim::Medication.locals.each do |m|
        # m.master && m.update(companies: m.master.companies)
        if m.master && (joins = m.master.companies_medications).present?
          joins.each do |join|
            m.companies_medications.where(company_uid: join.company_uid).first_or_create(
              begin_at: join.begin_at,
              end_at: join.end_at
            )
          end
        end
        printf '.'
      end
      puts ''
    end

    task :import => [:init, :cn_name]
  end
end
