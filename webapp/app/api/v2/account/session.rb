module V2::Account
  module Session
    class API < Grape::API
      include Trackable
      helpers AuthorizeHelper

      resource :session do
        # POST: /v2/account/session
        desc 'User Login'
        params do
          requires :user, type: Hash do
            optional :email, type: String, desc: 'Email'
            optional :phone, type: String, desc: 'Phone'
            requires :password, type: String, desc: 'Password'
            optional :remember_me, type: Integer, desc: 'Remember me'
            #exactly_one_of :email, :phone
          end
        end
        post { login }

        # DELETE: /v1/account/session
        desc 'User Logout'
        delete { logout }
      end
    end
  end
end
