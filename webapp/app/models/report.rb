class Report < ActiveRecord::Base
  belongs_to :user
  belongs_to :reportable, polymorphic: true

  validates :content, :user_id, :reportable_id, :reportable_type, presence: true

  delegate :email, to: :user, prefix: true, allow_nil: true
  delegate :human_type, to: :reportable, allow_nil: true
end

# == Schema Information
#
# Table name: reports
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  reportable_id   :integer
#  reportable_type :string(255)
#  content         :text
#  created_at      :datetime
#  updated_at      :datetime
#

