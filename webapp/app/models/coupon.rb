class Coupon < ActiveRecord::Base
  belongs_to :user
  belongs_to :created_by, polymorphic: true

  validates_uniqueness_of :code, scope: :source

  scope :from_source, ->(source) { where(source: source) }
  scope :available, -> { where(used: false) }
end
