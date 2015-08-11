module CegedimImport
  module Hospital
    extend ActiveSupport::Concern
    included do
      DEPARTMENT_FILE = Rails.root.join('tmp', 'cegedim', 'departments.xlsx').to_s
    end

    def save_department(data)
      if is_department?(data)
        if hospital = Cegedim::Hospital.find_by(uid: data[0])
          Cegedim::Department.where(uid: data[3]).first_or_create(name: data[4], hospital_uid: data[0])
        elsif ['ETA', 'GOR'].include?(data[2])
          hospital = save_hospital(data)
          Cegedim::Department.where(uid: data[3]).first_or_create(name: data[4], hospital_uid: hospital.uid)
        elsif ['SER', 'SSE'].include?(data[2]) # Main department,which has many sub departments
          hospital_uid = Cegedim::Department.find_by(uid: data[0]).try(:hospital_uid)
          Cegedim::Department.where(uid: data[3]).first_or_create(name: data[4], hospital_uid: hospital_uid)
        end
      elsif data[6] == 'ETA' and data[0] != data[3] # 分院
        save_sub_hospital(data)
      end
      printf '.'
    end

    def save_hospital(data)
      status = data[23] == '营业' ? 'open' : 'close'
      h_class = ['无', '#N/A'].include?(data[19]) ? nil : data[19]
      hospital = Cegedim::Hospital.where(uid: data[0]).first_or_initialize
      hospital.assign_attributes(
        name: data[1],
        official_name: data[5].presence,
        phone: data[24],
        address: data[30],
        post_code: data[28],
        city: data[27],
        district: data[29],
        h_type: data[10],
        h_class: h_class,
        status: status
      )
      hospital.save
      hospital
    end

    def save_sub_hospital(data)
      status = data[23] == '营业' ? 'open' : 'close'
      h_class = ['无', '#N/A'].include?(data[19]) ? nil : data[19]
      Cegedim::Hospital.where(uid: data[3], parent_uid: data[0]).first_or_create(
        name: data[4],
        official_name: data[5].presence,
        phone: data[24],
        address: data[30],
        post_code: data[28],
        city: data[27],
        district: data[29],
        h_type: data[10],
        h_class: h_class,
        status: status
      )
    end

    def is_department?(data)
      ['SER', 'SSE'].include? data[6]
    end
  end

  module Physician
    extend ActiveSupport::Concern
    included do
      PHYSICIAN_FILE = Rails.root.join('tmp', 'cegedim', 'physicians.xlsx').to_s
      DEPARTMENTS_PHYSICIANS_FILE = Rails.root.join('tmp', 'cegedim', 'departments_physicians.xlsx').to_s
    end

    def save_physician(data)
      name = "#{data[1]}#{data[2]}"
      status = data[8].to_s == '3' ? 'available' : 'unknown'
      physician = Cegedim::Physician.where(uid: data[0]).first_or_create(
        name: name,
        position: data[3],
        gender: data[7].downcase,
        status: status
      )
      if pick_speciality(data[4]).present?
        specialty_1 = Cegedim::Speciality.where(name: pick_speciality(data[4])).first_or_create
        Cegedim::PhysiciansSpeciality.where(physician_uid: physician.uid, speciality_id: specialty_1.id).first_or_create(priority: 1)
      end
      if pick_speciality(data[5]).present?
        specialty_2 = Cegedim::Speciality.where(name: pick_speciality(data[5])).first_or_create
        Cegedim::PhysiciansSpeciality.where(physician_uid: physician.uid, speciality_id: specialty_2.id).first_or_create(priority: 2)
      end
      if pick_speciality(data[6]).present?
        specialty_3 = Cegedim::Speciality.where(name: pick_speciality(data[6])).first_or_create
        Cegedim::PhysiciansSpeciality.where(physician_uid: physician.uid, speciality_id: specialty_3.id).first_or_create(priority: 3)
      end
      printf '.'
    end

    def link_department_and_physician(data)
      if physician = Cegedim::Physician.find_by(uid: data[10])
        if department = Cegedim::Department.find_by(uid: data[9]) # Link to a department
          physician.update(department_uid: department.uid, hospital_uid: department.hospital_uid)
          printf '.'
        elsif hospital = Cegedim::Hospital.find_by(uid: data[9]) # Link to a hospital, if department not found
          physician.update(hospital_uid: hospital.uid)
          printf '.'
        else
          puts ''
          puts "Can't find department with uid: #{data[9]}"
          puts ''
        end
      else
        puts ''
        puts "Can't find physician with uid: #{data[10]}"
        puts ''
      end
    end

    def pick_speciality(str)
      return nil if str == 'N/A'
      return str unless str.include?('>')
      str.split('>').last
    end
  end

  module Medication
    extend ActiveSupport::Concern
    included do
      MEDICATION_MASTER_FILE = Rails.root.join('tmp', 'cegedim', 'medication', 'medications.master.xlsx').to_s
      MEDICATION_LOCAL_FILE = Rails.root.join('tmp', 'cegedim', 'medication', 'medications.local.xlsx').to_s
      MEDICATION_COMPANIES_FILE = Rails.root.join('tmp', 'cegedim', 'medication', 'medications.companies.xlsx').to_s
    end

    def save_master_medication(data)
      Cegedim::Medication.where(uid: data[0].to_i).first_or_create(code: data[2], en_name: data[3], cn_name: data[4])
      printf '.'
    end

    def save_local_medication(data)
      master = Cegedim::Medication.find_by(uid: data[0].to_i)
      Cegedim::Medication.where(uid: data[1].to_i).first_or_create(master_uid: master.try(:uid), code: master.try(:code), en_name: data[2], cn_name: data[3], otc: data[6], old_companies: master.try(:old_companies), dosage1: data[7], dosage2: data[8], dosage3: data[9])

      if master.blank?
        puts ''
        puts "Can't find master with uid: #{data[0].to_i}"
      end
      printf '.'
    end

    def link_medication_and_company(data)
      if medication = Cegedim::Medication.find_by(uid: data[1].to_i)
        return if data[4].blank?
        if medication.old_companies.present?
          medication.old_companies += [data[4]] unless medication.companies.include?(data[4])
        else
          medication.old_companies = [data[4]]
        end
        if medication.changed?
          medication.save
          printf '.'
        end
      else
        puts ''
        puts "Can not found, company_uid: #{data[0].to_i}, medication_id: #{data[1].to_i}"
        puts ''
      end
    end
  end
end
