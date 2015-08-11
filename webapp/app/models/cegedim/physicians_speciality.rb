class Cegedim::PhysiciansSpeciality < ActiveRecord::Base
  belongs_to :physician, foreign_key: 'physician_uid', primary_key: 'uid'
  belongs_to :speciality
  validates_uniqueness_of :physician_uid, scope: :speciality_id
end

# == Schema Information
#
# Table name: cegedim_physicians_specialities
#
#  id            :integer          not null, primary key
#  physician_uid :string(255)
#  speciality_id :integer
#  priority      :integer          default(1)
#  created_at    :datetime
#  updated_at    :datetime
#

