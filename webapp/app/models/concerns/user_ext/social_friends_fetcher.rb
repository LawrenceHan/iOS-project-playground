require 'httparty'

module UserExt
  module SocialFriendsFetcher
    extend ActiveSupport::Concern

    included do
      SOCIAL_REQUEST_URL = {
        weibo: 'https://api.weibo.com/2/friendships/friends/ids.json',
        tqq: 'http://open.t.qq.com/api/friends/idollist_s',
        facebook: 'https://graph.facebook.com/v2.0/me/friends'
      }
    end

    module ClassMethods
      def update_social_friends
        joins(:authentications).find_each(batch_size: 100) do |user|
          user.update_social_friends
        end
      end

      def get_user_ids_by_uids(provider, uids)
        return [] if uids.blank?
        uids.map!(&:to_s)
        self.includes(:authentications).where('authentications.provider = ?', provider.to_s).where('authentications.uid IN (?)', uids).references(:authentications).pluck('users.id')
      end
    end

    def update_social_friends
      self.profile || self.build_profile
      if APP_CONFIG[:node] == 'india'
        self.profile.assign_attributes(social_friends: {"twitter" => twitter_friends, "facebook" => facebook_friends})
      else
        self.profile.assign_attributes(social_friends: {"weibo" => weibo_friends, "tqq" => tqq_friends})
      end
      self.profile.save if (!self.profile.persisted? || self.profile.changed?)
    end

    def weibo_friends
      return [] if self.weibo_auth.blank?
      query = {uid: self.weibo_auth.uid, access_token: self.weibo_auth.token}.to_query
      response = ::ActiveSupport::JSON.decode(HTTParty.get("#{User::SOCIAL_REQUEST_URL[:weibo]}?#{query}").body) rescue {}
      return [] if response.blank? || response['ids'].blank?
      uids = response['ids']
      User.get_user_ids_by_uids(:weibo, uids)
    end

    def tqq_friends
      return [] if self.tqq_auth.blank?
      query = {format: :json, reqnum: 200, mode: 0, install: 0, startindex: 0, oauth_version: '2.a', oauth_consumer_key: APP_CONFIG[:auth][:tqq][:app_id],
               openid: self.tqq_auth.uid, access_token: self.tqq_auth.token}.to_query
      response = ::ActiveSupport::JSON.decode(HTTParty.get("#{User::SOCIAL_REQUEST_URL[:tqq]}?#{query}").body) rescue {}
      return [] if response.blank? || response['data'].blank? || response['data']['info'].blank?
      uids = response['data']['info'].map {|x| x['openid']}
      User.get_user_ids_by_uids(:tqq, uids)
    end

    def twitter_friends
      return [] if self.twitter_auth.blank?
      client = Twitter::REST::Client.new(
        consumer_key: APP_CONFIG[:auth][:twitter][:app_id],
        consumer_secret: APP_CONFIG[:auth][:twitter][:app_secret],
        access_token: self.twitter_auth.token,
        access_token_secret: self.twitter_auth.token_secret
      )
      uids = client.friend_ids.attrs[:ids] rescue []
      User.get_user_ids_by_uids(:twitter, uids)
    end

    def facebook_friends
      return [] if self.facebook_auth.blank?
      # query = {fields: 'id', access_token: self.facebook_auth.token}.to_query
      query = {access_token: self.facebook_auth.token}.to_query
      response = ::ActiveSupport::JSON.decode(HTTParty.get("#{User::SOCIAL_REQUEST_URL[:facebook]}?#{query}").body) rescue {}
      uids =  (response['data'] && response['data'].map(&:values).flatten) rescue []
      User.get_user_ids_by_uids(:facebook, uids)
    end

  end
end
