class ReferralCode < ActiveRecord::Base
  default_scope -> { order(id: :desc) }
  attr_accessor :count
  has_many :medical_experience
  validates :code, uniqueness: true, presence: true

  before_validation :generate_referral_code

  def self.get_id_by_code(code)
    where(code: code).pluck(:id).first
  end

  def self.generate_code_by_count(count=10)
    return [] if count.zero?
    referral_codes = []
    count.times { referral_codes.unshift(self.create!) }
    referral_codes
  end

  def generate_referral_code
    return true if self.code.present?
    loop do
      code = generate_code
      unless ReferralCode.where(code: code).any?
        self.code = code
        break
      end
    end
  end

  private
  def generate_code(size=7)
    chars = ('0'..'9').to_a + ('A'..'Z').to_a
    (0...size).collect { chars[Kernel.rand(chars.length)] }.join
  end
end

# == Schema Information
#
# Table name: referral_codes
#
#  id                        :integer          not null, primary key
#  code                      :string(255)
#  memo                      :string(255)
#  medical_experiences_count :integer          default(0)
#  created_at                :datetime
#  updated_at                :datetime
#

