namespace :departments do
  desc 'export to gbi'
  task :export_to_gbi => :environment do
    CSV.open("departments.csv", "wb") do |csv|
      csv << %i(hospital_id hospital_name id name)
      Hospital.find_each do |hospital|
        hospital.departments.each do |department|
          csv << [hospital.id, hospital.name, department.id, department.name]
        end
      end
    end
  end

  desc 'translate departments'
  task :translate => :environment do
    docs = File.read(Rails.root.join('spec/tasks/departments.csv'))
    CSV.parse(docs, headers: true) do |row|
      department = Department.find row['id']
      chinese_name = department.name
      I18n.locale = 'en'
      department.name = row['english']
      department.save
      I18n.locale = 'zh-CN'
      department.name = chinese_name
      department.save
    end
  end
end
