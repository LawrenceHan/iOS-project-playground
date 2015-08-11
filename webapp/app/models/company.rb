class Company < ActiveRecord::Base
  has_many :companies_medications, dependent: :destroy
  has_many :medications, through: :companies_medications

  validates :vendor_id, uniqueness: true

  def name
    self[:cn_name].presence || self[:en_name]
  end
end

# == Schema Information
#
# Table name: companies
#
#  id         :integer          not null, primary key
#  vendor_id  :integer
#  en_name    :string(255)
#  cn_name    :string(255)
#  created_at :datetime
#  updated_at :datetime
#

