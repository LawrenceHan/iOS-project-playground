class Comment < ActiveRecord::Base
  STATUS = %w(pending rejected unread read)
  VALID_STATUS = 'unread'
  include BlacklistChecking

  belongs_to :user
  belongs_to :writer, class_name: 'User'
  has_many :reports, as: :reportable, dependent: :destroy

  validates :writer_id, :user_id, :content, presence: true
  validates :status, inclusion: { in: STATUS }
  validates :content, length: { minimum: 10 }

  delegate :email, to: :writer, prefix: true
  delegate :email, to: :user, prefix: true

  STATUS.each do |status|
    scope status, -> { where(status: status) }
  end

  def human_name
    self.class.model_name.human
  end

  def pass!
    update_attributes!(status: 'unread')
  end

end

# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  writer_id  :integer
#  user_id    :integer
#  content    :text
#  status     :string(255)      default("pending")
#  created_at :datetime
#  updated_at :datetime
#

