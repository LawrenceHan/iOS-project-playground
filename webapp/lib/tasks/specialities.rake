namespace :specialities do
  desc 'translate specialities'
  task :translate => :environment do
    docs = File.read(Rails.root.join('spec/tasks/specialities.csv'))
    CSV.parse(docs, headers: true) do |row|
      pairs = []
      if row['Chinese'].index(",")
        pairs = row['Chinese'].split(",").zip(row['English'].split(","))
      else
        pairs = [[row['Chinese'], row['English']]]
      end
      pairs.each do |pair|
        chinese_name, english_name = *pair
        speciality = Speciality.find_by name: chinese_name
        I18n.locale = 'en'
        speciality.name = english_name
        speciality.save
        I18n.locale = 'zh-CN'
        speciality.name = chinese_name
        speciality.save
      end
    end
  end
end
