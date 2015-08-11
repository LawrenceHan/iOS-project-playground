class Cegedim::Medication < ActiveRecord::Base
  has_many :companies_medications, foreign_key: 'medication_uid', primary_key: 'uid', dependent: :destroy
  has_many :companies, through: :companies_medications
  belongs_to :master, class_name: 'Cegedim::Medication', foreign_key: 'master_uid', primary_key: 'uid'

  scope :locals, -> { where.not(master_uid: nil)}
end

# == Schema Information
#
# Table name: cegedim_medications
#
#  id            :integer          not null, primary key
#  uid           :integer
#  master_uid    :integer
#  old_companies :string(255)      default([]), is an Array
#  code          :string(255)
#  en_name       :string(255)
#  cn_name       :string(255)
#  otc           :integer
#  dosage1       :string(255)
#  dosage2       :string(255)
#  dosage3       :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#
