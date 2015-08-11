module V2::Account
  module Password
    class API < Grape::API

      helpers AuthorizeHelper

      resource :password do

        desc 'Send reset password email'
        params do
          optional :email, type: String, desc: 'User email'
          optional :phone, type: String, desc: 'User phone'
        end
        post :recover do
          if params[:email].present?
            if user = User.where(email: params[:email]).first
              user.send_reset_password_instructions
              say_succeed
            else
              say_failed I18n.t('api.password.email_not_exist')
            end
          elsif params[:phone].present?
            if user = User.where(phone: params[:phone]).first
              user.send_reset_password_instructions_via_sms
              say_succeed
            else
              say_failed I18n.t('api.password.phone_doesnt_exist')
            end
          else
            say_failed I18n.t('api.password.invalid_call')
          end
        end

        desc 'Update password [require login]'
        params do
          requires :user, type: Hash do
            # requires :email, type: String, desc: 'Email'
            requires :current_password, type: String, desc: 'Current Password'
            requires :password, type: String, desc: 'New Password'
            requires :password_confirmation, type: String, desc: 'New Password Confirmation'
          end
        end
        post :update do
          authenticate!
          if current_user.authenticate(params[:user][:current_password])
            if current_user.reset_password!(params[:user][:password], params[:user][:password_confirmation])
              say_succeed({}, status: 200)
            else
              say_failed current_user
            end
          else
            say_failed I18n.t('api.password.password_not_correct')
          end
        end
      end
    end
  end
end
