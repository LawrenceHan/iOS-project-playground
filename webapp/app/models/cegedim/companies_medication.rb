class Cegedim::CompaniesMedication < ActiveRecord::Base
  belongs_to :company, foreign_key: 'company_uid', primary_key: 'uid'
  belongs_to :medication, foreign_key: 'medication_uid', primary_key: 'uid'
end

# == Schema Information
#
# Table name: cegedim_companies_medications
#
#  id             :integer          not null, primary key
#  company_uid    :integer
#  medication_uid :integer
#  begin_at       :date
#  end_at         :date
#  created_at     :datetime
#  updated_at     :datetime
#

