class Authentication < ActiveRecord::Base
  belongs_to :user

  validates :user_id, :provider, :uid, :token, presence: true
  validates :provider, inclusion: { in: %w(weibo tqq facebook twitter) }
  validates_uniqueness_of :uid, scope: :provider

  delegate :email, to: :user, prefix: true

  def human_provider
    case provider
    when 'weibo' then I18n.t('social_network.weibo')
    when 'tqq'   then I18n.t('social_network.tqq')
    when 'facebook'   then I18n.t('social_network.facebook')
    when 'twitter'   then I18n.t('social_network.twitter')
    end
  end
end

# == Schema Information
#
# Table name: authentications
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  provider     :string(255)
#  uid          :string(255)
#  token        :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  token_secret :string(255)
#

