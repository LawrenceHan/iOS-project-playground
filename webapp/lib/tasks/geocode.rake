namespace :geocode do
  desc 'Export hospital geocode to yaml file'
  task :export => :environment do
    geo_file = Rails.root.join('db', 'seeds', 'geocode.yml').to_s
    File.open(geo_file, "w") {|f| f.puts Hospital.all.as_json(only: [:vendor_id, :latitude, :longitude]).to_yaml }
  end

  desc 'Import geocode to hospital'
  task :import => :environment do
    geo_file = Rails.root.join('db', 'seeds', 'geocode.yml').to_s
    geocode = File.open(geo_file) { |file| YAML.load(file) }

    geocode.each do |geo|
      if h = Hospital.find_by(vendor_id: geo['vendor_id'])
        h.assign_attributes(geo)
        h.save if h.changed?
        printf '.'
      else
        puts "Can't found hospital with vendor_id=#{geo['vendor_id']}"
        puts ''
      end
    end
    puts ''
  end
end
