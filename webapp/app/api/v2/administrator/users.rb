module V2::Administrator
  module Users
    class API < Grape::API

      helpers AdminAuthorizeHelper

      before do
        authenticate!
      end

      resource :users do
        params do
          requires :phone, type: String
          requires :sms_token, type: String
        end
        put ':phone/verify' do
          $redis.set params[:phone], params[:sms_token]
        end
      end
    end
  end
end
