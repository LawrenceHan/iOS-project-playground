module HospitalMerging
  extend ActiveSupport::Concern

  # Merge an hospital into another
  def merge_into!(another_hospital)
    raise "Can't merge into itself" if self == another_hospital
    raise "Can't merge non-persisted hospital" unless self.persisted? && another_hospital.persisted?

    # Move departments assignments to another hospital
    # FIXME - Will need to update this logic when department-hospital will be one to many - #58
    self.departments_hospitals.each do |department_hospital|
      if another_hospital.departments.include?(department_hospital.department)
        department_hospital.destroy
      else
        department_hospital.update_attribute(:hospital_id, another_hospital.id)
      end
    end

    # Move physicians to another_hospital
    self.physicians.update_all hospital_id: another_hospital.id

    # Move medical experiences to another hospital
    self.medical_experiences.update_all hospital_id: another_hospital.id

    # Move hospital reviews to another hospital
    self.hospital_reviews.update_all reviewable_id: another_hospital.id

    # Move sub-hospitals
    self.sub_hospitals.update_all parent_id: another_hospital.id

    # Update avg waiting time
    another_hospital.update_avg_waiting_time!

    # Update avg rating
    another_hospital.update_avg_rating!

    # Auto-destroy!
    self.reload.destroy
  end

  # Another syntax for merging hospital
  def absorb!(another_hospital)
    another_hospital.merge_into!(self)
  end
end
