require 'roo'
require 'json'

namespace :db do
  namespace :doctors do
    desc 'Import each row as a JSON document'
    task :doc, [:file_path] => :environment do |t, args|
      puts 'Importing document for ' + args[:file_path]
      puts 'Loading data file ...'
      s = Roo::Excelx.new(args[:file_path])
      s.default_sheet = s.sheets.first

      puts 'Calculating count ...'
      row_count = s.last_row
      puts "Begin to import #{row_count - 1} documents..."
      headers = s.row(1)
      key_to_index = Hash[headers.zip (0..headers.size)]
      if not key_to_index['vendor_id'] then
        abort("Error! Required header vendor_id is missing")
      end
      (2..row_count).each do |i|
        data = s.row(i)
        vendor_id = data[key_to_index['vendor_id']]
        physician = Physician.find_by(vendor_id: vendor_id)
        if physician
          physician.doc = Hash[key_to_index.keys.map { |k|
            d = data[key_to_index[k]]
            d.strip! if d
            [k, d]
          }].to_json
          physician.save
          printf '.'
        else
            puts "Warning: #{vendor_id} not found in the database"
        end
      end
      puts ''
    end
  end
end
