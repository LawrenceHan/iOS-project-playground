class Condition < HealthCondition
end

# == Schema Information
#
# Table name: health_conditions
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  category   :string(255)
#  type       :string(30)
#

