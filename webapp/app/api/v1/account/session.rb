module V1::Account
  module Session
    class API < Grape::API
      include Trackable
      helpers AuthorizeHelper

      resource :session do
        # POST: /v1/account/session
        desc 'User Login'
        params do
          requires :user, type: Hash do
            requires :email, type: String, desc: 'Email'
            requires :password, type: String, desc: 'Password'
            optional :remember_me, type: Integer, desc: 'Remember me'
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
