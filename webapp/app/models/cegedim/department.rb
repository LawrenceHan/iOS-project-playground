class Cegedim::Department < ActiveRecord::Base
  belongs_to :hospital, foreign_key: 'hospital_uid', primary_key: 'uid'
  has_many :physicians, foreign_key: 'department_uid', primary_key: 'uid'
end

# == Schema Information
#
# Table name: cegedim_departments
#
#  id           :integer          not null, primary key
#  uid          :string(255)
#  hospital_uid :string(255)
#  name         :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

