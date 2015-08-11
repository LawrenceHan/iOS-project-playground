class Cegedim::Physician < ActiveRecord::Base
  belongs_to :hospital, foreign_key: 'hospital_uid', primary_key: 'uid'
  belongs_to :department, foreign_key: 'department_uid', primary_key: 'uid'
  has_many :physicians_specialities, foreign_key: 'physician_uid', primary_key: 'uid'
  has_one :first_physicians_speciality, -> { where(priority: 1) }, foreign_key: 'physician_uid', primary_key: 'uid', class_name: '::Cegedim::PhysiciansSpeciality'
  has_one :second_physicians_speciality, -> { where(priority: 2) }, foreign_key: 'physician_uid', primary_key: 'uid', class_name: '::Cegedim::PhysiciansSpeciality'
  has_one :third_physicians_speciality, -> { where(priority: 3) }, foreign_key: 'physician_uid', primary_key: 'uid', class_name: '::Cegedim::PhysiciansSpeciality'
  has_one :first_speciality, through: :first_physicians_speciality, source: :speciality
  has_one :second_speciality, through: :second_physicians_speciality, source: :speciality
  has_one :third_speciality, through: :third_physicians_speciality, source: :speciality
end

# == Schema Information
#
# Table name: cegedim_physicians
#
#  id             :integer          not null, primary key
#  uid            :string(255)
#  department_uid :string(255)
#  hospital_uid   :string(255)
#  name           :string(255)
#  position       :string(255)
#  gender         :string(255)
#  birthdate      :date
#  status         :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

