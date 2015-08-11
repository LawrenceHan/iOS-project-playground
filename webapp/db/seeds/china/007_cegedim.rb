puts 'Import cegedim data ...'

if Rails.env.development?
  Cegedim::PhysiciansSpeciality.destroy_all
  Cegedim::CompaniesMedication.destroy_all
  Cegedim::Speciality.destroy_all
  Cegedim::Physician.destroy_all
  Cegedim::Medication.destroy_all
  Cegedim::Hospital.destroy_all
  Cegedim::Department.destroy_all
  Cegedim::Company.destroy_all

  companies_attrs = JSON.parse File.read(Rails.root.join('db/seeds/china/companies.json'))
  companies_attrs.each { |company_attrs| Cegedim::Company.create company_attrs }

  departments_attrs = JSON.parse File.read(Rails.root.join('db/seeds/china/departments.json'))
  departments_attrs.each { |department_attrs| Cegedim::Department.create department_attrs }

  hospitals_attrs = JSON.parse File.read(Rails.root.join('db/seeds/china/hospitals.json'))
  hospitals_attrs.each { |hospital_attrs| Cegedim::Hospital.create hospital_attrs }

  medications_attrs = JSON.parse File.read(Rails.root.join('db/seeds/china/medications.json'))
  medications_attrs.each { |medication_attrs| Cegedim::Medication.create medication_attrs }

  physicians_attrs = JSON.parse File.read(Rails.root.join('db/seeds/china/physicians.json'))
  physicians_attrs.each { |physician_attrs| Cegedim::Physician.create physician_attrs }

  specialities_attrs = JSON.parse File.read(Rails.root.join('db/seeds/china/specialities.json'))
  specialities_attrs.each { |speciality_attrs| Cegedim::Speciality.create speciality_attrs }

  companies_medications_attrs = JSON.parse File.read(Rails.root.join('db/seeds/china/companies_medications.json'))
  companies_medications_attrs.each { |companies_medication_attrs| Cegedim::CompaniesMedication.create companies_medication_attrs }

  physicians_specialities_attrs = JSON.parse File.read(Rails.root.join('db/seeds/china/physicians_specialities.json'))
  physicians_specialities_attrs.each { |physicians_speciality_attrs| Cegedim::PhysiciansSpeciality.create physicians_speciality_attrs }
else
  Rake::Task['cegedim_bak:import'].invoke
end

puts ''
