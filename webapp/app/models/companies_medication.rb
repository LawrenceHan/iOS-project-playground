class CompaniesMedication < ActiveRecord::Base
  belongs_to :company
  belongs_to :medication
end

# == Schema Information
#
# Table name: companies_medications
#
#  id            :integer          not null, primary key
#  company_id    :integer
#  medication_id :integer
#  begin_at      :date
#  end_at        :date
#  created_at    :datetime
#  updated_at    :datetime
#

