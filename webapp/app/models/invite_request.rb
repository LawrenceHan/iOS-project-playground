class InviteRequest < ActiveRecord::Base
  belongs_to :user

  delegate :email, to: :user, prefix: true

  def human_emails
    self[:emails].to_a.delete_if(&:blank?).join(', ')
  end
end

# == Schema Information
#
# Table name: invite_requests
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  emails     :string(255)      default([]), is an Array
#  created_at :datetime
#  updated_at :datetime
#
