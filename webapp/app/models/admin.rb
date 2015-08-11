class Admin < ActiveRecord::Base
  acts_as_messageable

  # TODO: hardcoded email should be extracted
  CEGEDIM_EMAIL = 'jonathan.dairion@cegedim.com'

  has_secure_password
  validates :email, uniqueness: true, email: true

  def cegedim_guy?
    self.email == CEGEDIM_EMAIL
  end
end

# == Schema Information
#
# Table name: admins
#
#  id              :integer          not null, primary key
#  email           :string(255)
#  password_digest :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

