class Cegedim::Hospital < ActiveRecord::Base
  has_many :departments, foreign_key: 'hospital_uid', primary_key: 'uid'
  has_many :physicians, foreign_key: 'hospital_uid', primary_key: 'uid'
end

# == Schema Information
#
# Table name: cegedim_hospitals
#
#  id            :integer          not null, primary key
#  uid           :string(255)
#  parent_uid    :string(255)
#  name          :string(255)
#  official_name :string(255)
#  phone         :string(255)
#  address       :string(255)
#  post_code     :string(255)
#  city          :string(255)
#  district      :string(255)
#  h_type        :string(255)
#  h_class       :string(255)
#  status        :string(255)      default("open")
#  created_at    :datetime
#  updated_at    :datetime
#

