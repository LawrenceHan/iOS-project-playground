namespace :physicians do
  desc 'export to gbi'
  task :export_to_gbi => :environment do
    CSV.open("physicians.csv", "wb") do |csv|
      csv << %i(id name position birthdate gender hospital_name department_name)
      Physician.includes(:hospital, :department).find_each do |physician|
        csv << [physician.id, physician.name, physician.position, physician.birthdate, physician.gender, physician.hospital.try(:name), physician.department.try(:name)]
      end
    end
  end

  desc 'add new physicians'
  task :add_new => :environment do
    GENDERS = { 'F' => 'female', 'M' => 'male' }
    docs = File.read(Rails.root.join('spec/tasks/physicians_edition_2.csv'))
    CSV.parse(docs, headers: true) do |row|
      if row['id']
        physician = Physician.new
        hospital_id = Hospital::Translation.find_by(name: row['Hospitals They work in'].split(',').first.gsub(/[[:blank:]]$/, '')).hospital_id
        I18n.locale = 'zh-CN'
        physician.name = "#{row['nom_zh']}#{row['prenom_zh']}"
        physician.gender = GENDERS[row['sexe']] || 'unknown'
        physician.description = row['descr_zh']
        physician.hospital_id = hospital_id
        physician.save
        I18n.locale = 'en-US'
        physician.name = "#{row['prenom']}#{row['nom']}"
        physician.description = row['descr_en']
        physician.save
      end
    end
  end

  desc 'sync physician pics'
  task :sync_pics => :environment do
    Physician.where.not(doc: nil).find_each do |physician|
      physician.remote_avatar_url = "http://m.kangyu.co/microsites/images/pics/#{physician.vendor_id}.jpg"
      puts "sync physician #{physician.id} with http://m.kangyu.co/microsites/images/pics/#{physician.vendor_id}.jpg"
      physician.save
    end
  end
end
