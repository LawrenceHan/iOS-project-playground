class Department < ActiveRecord::Base
  translates :name, fallbacks_for_empty_translations: true

  include AggregatedSearchable

  has_many :departments_hospitals, dependent: :destroy
  has_many :hospitals, through: :departments_hospitals

  has_many :physicians, dependent: :nullify
  has_many :physician_reviews, through: :physicians
  has_many :published_physician_reviews, -> { where(status: 'published') }, through: :physicians

  default_scope -> { preload(:translations) }

  validates :name, presence: true

  def physicians_count
    physicians.size
  end

  def searchable_json
    as_json(only: [:id, :name], methods: [:class_name, :physicians_count])
  end
end

# == Schema Information
#
# Table name: departments
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  vendor_id  :string(255)
#
