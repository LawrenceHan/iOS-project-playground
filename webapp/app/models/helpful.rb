class Helpful < ActiveRecord::Base
  belongs_to :review, counter_cache: true
  belongs_to :user

  validates_uniqueness_of :user_id, scope: :review_id
end

# == Schema Information
#
# Table name: helpfuls
#
#  id         :integer          not null, primary key
#  review_id  :integer
#  user_id    :integer
#  created_at :datetime
#

