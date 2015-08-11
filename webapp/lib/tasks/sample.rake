require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'
require 'google_drive/google_drive.rb'

namespace :sample do
  desc "get sample and measure accuracy of the database"
  task :accuracy, [:file_id] => :environment do |task, args|
    my_drive = GoogleDrive::Api.new
    result = my_drive.download_file(args.file_id)
    correct_count = 0

    if result
      cleaned_data = Hash.new{|hash, key| hash[key] = Hash.new}
      CSV.parse(result, headers: true) do |row|
        cleaned_data[row['ENTITY']][row['ID']] = row
      end

      total_count = 0
      cleaned_data.each do |name, rows|
        entities = name.classify.constantize.find(rows.keys)
        entities.each do |item|
          if cleaned_data[name][item.id.to_s]['VALUE']
            value =  cleaned_data[name][item.id.to_s]['VALUE'].to_s
          end
          key = cleaned_data[name][item.id.to_s]['KEY']
          if item[key] == value
            correct_count +=1
          end
          total_count += 1
        end
      end
      puts "we have #{correct_count} correct values in th sample"
      puts "the accuracy is : #{((correct_count.to_f / total_count.to_f) * 100).to_i}%"
    end
  end

  desc "update one attribute by hospitals with specific file from google drive"
  task :update, [:file_id] => :environment do |task, args|
    my_drive = GoogleDrive::Api.new()
    result = my_drive.download_file(args.file_id)

    if result
      cleaned_data = Hash.new{|hash, key| hash[key] = Hash.new}
      CSV.parse(result, headers: true) do |row|
        cleaned_data[row['ENTITY']][row['ID']] = row
      end

      cleaned_data.each do |name, rows|
        entities = name.classify.constantize.find(rows.keys)
        entities.each do |item| 
          item.update({cleaned_data[name][item.id.to_s]['KEY'] => cleaned_data[name][item.id.to_s]['VALUE']})
        end
      end
    end
  end

  desc "export sample of data into a csv file and upload it on google drive"
  task :export, [:file_name,:desc,:parent_id] => :environment do |task, args|

    path_file = 'lib/tasks/sample_of_data.csv'
    entities_name = YAML::load(File.open('lib/tasks/data_to_check.yml'))
    total = entities_name.inject(0) do|sum, (k, x)| 
      sum += (k.classify.constantize.all.count * x['data_points'].size)
    end

    # Sample size formulas (http://williamgodden.com/samplesizeformula.pdf) 
    confidence_level = APP_CONFIG[:sample_size][:confidence_level] # percent confidence level (e.g., 1.96 for a 95)
    percentage_population = APP_CONFIG[:sample_size][:percentage_population] # Percentage of population picking a choice, expressed as decimal
    confidence_interval = APP_CONFIG[:sample_size][:confidence_interval] # Confidence interval, expressed as decimal (e.g., .04 = +/- 4 percentage points)

    sample_size = ((confidence_level**2) * percentage_population * (1-percentage_population)) / (confidence_interval**2)
    sample_size = (sample_size / (1 + ((sample_size-1) / total))).round
    rand_values = sample_size.times.map {rand(sample_size)}.sort

    offset = 0
    sample_datapoint = {}
    CSV.open(path_file, 'wb') do |csv|
      csv << ['ENTITY' ,'ID','KEY', 'VALUE']        
      entities_name.each do |name, attributes|
        percentage_of_data = ((name.classify.constantize.all.count * attributes['data_points'].size).to_f / total.to_f).round(2)
        offset += (sample_size * percentage_of_data).round
        tmp, rand_values = rand_values.partition{|e| e <= offset}
        name.classify.constantize.order('RANDOM()').limit(tmp.count)
        .each do |x|
          field = attributes['data_points'].sample
          csv << [name, x.id, field, x[field]]
        end 
      end
    end
    my_drive = GoogleDrive::Api.new()
    result = my_drive.insert_file(args.file_name, args.desc, args.parent_id, 'text/csv', path_file)
    FileUtils.rm(path_file)
  end
end

