class CreateDepartmentsHospitals < ActiveRecord::Migration
  def change
    create_table :departments_hospitals do |t|
      t.belongs_to :hospital, index: true
      t.belongs_to :department, index: true
    end

    Department.all.each do |d|
      if d.hospital_id? && (hospital = Hospital.find_by(id: d.hospital_id)).present?
        DepartmentsHospital.where(hospital_id: hospital.id, department_id: d.id).first_or_create
      end
    end

    remove_index(:departments, :hospital_id)
    remove_column(:departments, :hospital_id)
  end
end
