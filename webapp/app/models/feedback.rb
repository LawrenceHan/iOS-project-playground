class Feedback < ActiveRecord::Base
  attr_accessor :skip_notification

  belongs_to :user

  validates :user_id, :content, presence: true

  delegate :email, to: :user, prefix: true

  after_create :notify_the_administrators, if: ->(x) { !x.skip_notification }

  private
  def notify_the_administrators
    UserMailer.feedback_notify(user_email, self).deliver
  end
end

# == Schema Information
#
# Table name: feedback
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  content        :text
#  created_at     :datetime
#  updated_at     :datetime
#  app_version    :string(255)
#  device_model   :string(255)
#  system_version :string(255)
#

