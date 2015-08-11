class Cegedim::Speciality < ActiveRecord::Base
  has_many :physicians_specialities
  has_many :physicians, through: :physicians_specialities
end

# == Schema Information
#
# Table name: cegedim_specialities
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

