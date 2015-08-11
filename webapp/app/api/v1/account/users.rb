module V1::Account
  module Users
    class API < Grape::API

      helpers AuthorizeHelper

      before do
        authenticate!
      end

      resource :users do
        desc  'Change email or phone [require login]'
        params do
          optional :user, type: Hash do
            optional :email, type: String, desc: 'Email'
            optional :phone,  type: String, desc: 'Phone number'
          end
        end
        put :my do
          if current_user.update(get_params_data(:user, [:email, :phone]))
            say_succeed
          else
            say_failed current_user
          end
        end
      end

    end
  end
end
