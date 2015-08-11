require 'roo'
require 'cegedim_import'
include CegedimImport::Hospital
include CegedimImport::Physician
include CegedimImport::Medication

namespace :cegedim_bak do
  desc 'Clean Cegedim tables'
  task :clean => :environment do
    puts 'Clean old data ...'
    %w(hospital physician department speciality physicians_speciality).each do |c|
      "Cegedim::#{c.classify}".constantize.delete_all
    end
  end

  desc 'Import workflow'
  task :import => [:clean, 'import:all']

  namespace :import do
    desc 'Import departments and hospitals'
    task :department => :environment do
      puts 'Importing hospitals and departments ...'
      puts 'Loading data file ...'
      s = Roo::Excelx.new(DEPARTMENT_FILE)
      s.default_sheet = s.sheets.first
      puts 'Calculating hospitals and departments count ...'
      row_count = s.last_row
      puts "Begin to import #{row_count - 1} hospitals and departments ..."
      (2..row_count).each {|i| save_department(s.row(i)) }
      puts ''
    end

    desc 'Import physicians to DB'
    task :physician => :environment do
      puts 'Importing physicians ...'
      puts 'Loading data file ...'
      s = Roo::Excelx.new(PHYSICIAN_FILE)
      s.default_sheet = s.sheets.first
      puts 'Calculating physicians count ...'
      row_count = s.last_row
      puts "Begin to import #{row_count - 1} physicians ..."
      (2..row_count).each {|i| save_physician(s.row(i)) }
      puts ''
    end

    desc 'Import links between physician and department'
    task :link => :environment do
      puts 'Link physicians and departments ...'
      puts 'Loading link data file ...'
      s = Roo::Excelx.new(DEPARTMENTS_PHYSICIANS_FILE)
      s.default_sheet = s.sheets.first
      puts 'Calculating links count ...'
      row_count = s.last_row
      puts "Begin to import #{row_count - 1} links ..."
      (2..row_count).each {|i| link_department_and_physician(s.row(i)) }
      puts ''
    end

    namespace :medication do
      task :master => :environment do
        puts 'Importing master medications ...'
        puts 'Loading data file ...'
        s = Roo::Excelx.new(MEDICATION_MASTER_FILE)

        # Import master medications
        puts 'Importing master medications ...'
        s.default_sheet = s.sheets.first
        puts 'Calculating master medications count ...'
        row_count = s.last_row
        puts "Begin to import #{row_count - 1} master medications ..."
        (2..row_count).each {|i| save_master_medication(s.row(i)) }
        puts ''
      end

      desc 'Fill companies for master medications'
      task :fill_companies => :environment do
        puts 'Fill companies for master medications ...'
        puts 'Remove current companies ...'
        Cegedim::Medication.update_all(old_companies: [])

        puts 'Loading data file ...'
        s = Roo::Excelx.new(MEDICATION_COMPANIES_FILE)
        s.default_sheet = s.sheets.first
        puts 'Calculating links count ...'
        row_count = s.last_row
        puts "Begin to fill #{row_count - 1} companies ..."
        (2..row_count).each {|i| link_medication_and_company(s.row(i)) }
        puts ''
      end

      task :local => :environment do
        puts 'Importing local medications ...'
        puts 'Loading data file ...'
        s = Roo::Excelx.new(MEDICATION_LOCAL_FILE)
        s.default_sheet = s.sheets.first
        puts 'Calculating local medications count ...'
        row_count = s.last_row
        puts "Begin to import #{row_count - 1} local medications ..."
        (2..row_count).each {|i| save_local_medication(s.row(i)) }
        puts ''
      end

      task :all => [:master, :fill_companies, :local]
    end

    task :all => [:department, :physician, :link, 'medication:all']
  end
end
