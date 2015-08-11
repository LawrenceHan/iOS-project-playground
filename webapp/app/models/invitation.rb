class Invitation < ActiveRecord::Base
  has_one :owner, foreign_key: 'email', primary_key: 'owner_email', class_name: 'User'
  has_one :guest, foreign_key: 'email', primary_key: 'guest_email', class_name: 'User'
end

# == Schema Information
#
# Table name: invitations
#
#  id          :integer          not null, primary key
#  owner_email :string(255)
#  guest_email :string(255)
#  created_at  :datetime
#

