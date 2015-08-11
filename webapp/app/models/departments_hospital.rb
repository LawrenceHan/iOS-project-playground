class DepartmentsHospital < ActiveRecord::Base
  belongs_to :department
  belongs_to :hospital

  validates_uniqueness_of :department_id, scope: :hospital_id
end

# == Schema Information
#
# Table name: departments_hospitals
#
#  id            :integer          not null, primary key
#  hospital_id   :integer
#  department_id :integer
#
