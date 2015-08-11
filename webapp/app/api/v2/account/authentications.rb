module V2::Account
  module Authentications
    class API < Grape::API
      helpers AuthorizeHelper

      before do
        authenticate!
      end

      resource :authentications do
        desc 'Post Weibo/TencentWeibo authentication info [require login]'
        params do
          requires :provider, type: String, regexp: /^tqq|weibo|facebook|twitter$/, desc: 'Provider'
          requires :token, type: String, desc: 'Access token'
          requires :uid, type: String, desc: 'Uid (openid in TencentWeibo)'
        end
        post do
          auth_object = current_user.save_authentication(params[:provider], params)
          if auth_object.errors.empty?
            say_succeed
          else
            say_failed auth_object
          end
        end

        desc 'Unlink to Weibo/TencentWeibo [require login]'
        delete ':provider' do
          current_user.remove_authentication(params[:provider])
          say_succeed
        end

      end
    end
  end
end
