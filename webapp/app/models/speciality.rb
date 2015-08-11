class Speciality < ActiveRecord::Base
  translates :name, fallbacks_for_empty_translations: true

  include AggregatedSearchable

  has_many :physicians_specialities, dependent: :destroy
  has_many :physicians, through: :physicians_specialities
  has_many :hospitals, -> { uniq }, through: :physicians
  validates :name, presence: true#, uniqueness: true

  default_scope -> { preload(:translations) }

  def physicians_count
    physicians.size
  end

  def searchable_json
    as_json(only: [:id, :name], methods: [:class_name, :physicians_count])
  end
end

# == Schema Information
#
# Table name: specialities
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  vendor_id  :integer
#

