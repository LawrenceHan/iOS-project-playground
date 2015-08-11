module UserExt
  module Socialable
    extend ActiveSupport::Concern
    include Utils

    included do
      has_many :authentications, dependent: :destroy
      has_one :weibo_auth, -> { where(provider: 'weibo') }, class_name: "Authentication", dependent: :destroy
      has_one :tqq_auth, -> { where(provider: 'tqq') }, class_name: "Authentication", dependent: :destroy
      has_one :facebook_auth, -> { where(provider: 'facebook') }, class_name: "Authentication", dependent: :destroy
      has_one :twitter_auth, -> { where(provider: 'twitter') }, class_name: "Authentication", dependent: :destroy
      alias_method :linked_to_weibo, :linked_to_weibo?
      alias_method :linked_to_tqq, :linked_to_tqq?
      alias_method :linked_to_facebook, :linked_to_facebook?
      alias_method :linked_to_twitter, :linked_to_twitter?
    end

    def save_authentication(provider, auth_hash)
      case provider.to_s
      when 'weibo' then
        self.weibo_auth || self.build_weibo_auth(uid: auth_hash[:uid])
        self.weibo_auth.assign_attributes(token: auth_hash[:token])
        self.weibo_auth.save if (!self.weibo_auth.persisted? || self.weibo_auth.changed?)
        self.weibo_auth
      when 'tqq' then
        self.tqq_auth || self.build_tqq_auth(uid: auth_hash[:uid])
        self.tqq_auth.assign_attributes(token: auth_hash[:token])
        self.tqq_auth.save if (!self.tqq_auth.persisted? || self.tqq_auth.changed?)
        self.tqq_auth
      when 'facebook' then
        self.facebook_auth || self.build_facebook_auth(uid: auth_hash[:uid])
        self.facebook_auth.assign_attributes(token: auth_hash[:token])
        self.facebook_auth.save if (!self.facebook_auth.persisted? || self.facebook_auth.changed?)
        self.facebook_auth
      when 'twitter' then
        self.twitter_auth || self.build_twitter_auth(uid: auth_hash[:uid])
        self.twitter_auth.assign_attributes(token: auth_hash[:token], token_secret: auth_hash[:token_secret])
        self.twitter_auth.save if (!self.twitter_auth.persisted? || self.twitter_auth.changed?)
        self.twitter_auth
      end
    end

    def remove_authentication(provider)
      case provider.to_s
      when 'weibo'    then self.weibo_auth.destroy if self.weibo_auth.present?
      when 'tqq'      then self.tqq_auth.destroy if self.tqq_auth.present?
      when 'facebook' then self.facebook_auth.destroy if self.facebook_auth.present?
      when 'twitter'  then self.twitter_auth.destroy if self.twitter_auth.present?
      end
    end

    def linked_to_social?
      authentications.present?
    end

    def linked_to_weibo?
      weibo_auth.present?
    end

    def linked_to_tqq?
      tqq_auth.present?
    end

    def linked_to_facebook?
      facebook_auth.present?
    end

    def linked_to_twitter?
      twitter_auth.present?
    end

    def human_social_links
      authentications.pluck(:provider).map{|p| I18n.t("social_network.#{p}") }.join(',')
    end
  end

end
