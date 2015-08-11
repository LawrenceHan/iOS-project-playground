module V2::Administrator
  module Session
    class API < Grape::API

      helpers AdminAuthorizeHelper

      resource :session do
        # POST: /v2/admin/session
        desc 'Admin Login'
        params do
          requires :admin, type: Hash do
            requires :email, type: String, desc: 'Email'
            requires :password, type: String, desc: 'Password'
            optional :remember_me, type: Integer, desc: 'Remember me'
          end
        end
        post { login }

        # DELETE: /v2/admin/session
        desc 'Admin Logout'
        delete { logout }
      end
    end
  end
end
