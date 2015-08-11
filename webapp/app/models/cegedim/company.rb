class Cegedim::Company < ActiveRecord::Base
  has_many :companies_medications, foreign_key: 'company_uid', primary_key: 'uid', dependent: :destroy
  has_many :medications, through: :companies_medications
end

# == Schema Information
#
# Table name: cegedim_companies
#
#  id         :integer          not null, primary key
#  uid        :integer
#  en_name    :string(255)
#  cn_name    :string(255)
#  created_at :datetime
#  updated_at :datetime
#

