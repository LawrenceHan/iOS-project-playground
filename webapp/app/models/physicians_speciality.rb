class PhysiciansSpeciality < ActiveRecord::Base
  belongs_to :physician
  belongs_to :speciality

  def <=>(other)
    self.priority <=> other.priority
  end
end

# == Schema Information
#
# Table name: physicians_specialities
#
#  id            :integer          not null, primary key
#  physician_id  :integer
#  speciality_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#  priority      :integer
#

