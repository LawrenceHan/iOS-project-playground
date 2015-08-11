module V2::Account
  module Users
    class API < Grape::API

      helpers AuthorizeHelper

      before do
        authenticate!
      end

      resource :users do

        desc 'Change unconfirmed email address [require login]'
        params do
          requires :email, type: String, desc: 'Email'
        end
        put :change_email do
          current_user.unconfirmed_email = params[:email]
          current_user.send_confirmation_instructions
          if current_user.save
            say_succeed
          else
            say_failed current_user
          end
        end

        desc 'Change unconfirmed phone [require login]'
        params do
          requires :phone, type: String, desc: 'Email'
          requires :sms_token, type: String, desc: 'Sms validate token'
        end
        put :change_phone do
          if session[:sms_send_at].present? and
            (Time.now > session[:sms_send_at] + User.sms_validate_within) and
            !APP_CONFIG[:sms][:test_mode]
            return say_failed I18n.t('api.registration.sms.token_expired')
          end
          current_user.sms_token = params[:sms_token]
          current_user.phone = params[:phone]
          if session[:phone] && session[:sms_token]
            current_user.sms_token_match_with(session[:phone], session[:sms_token])
          else
            current_user.sms_token_match_with(params[:phone], $redis.get(params[:phone]))
          end

          if current_user.errors.empty? && current_user.save
            session[:phone] = nil
            session[:sms_token] = nil
            session[:sms_send_at] = nil
            $redis.del(params[:phone])
            say_succeed
          else
            say_failed current_user
          end
        end
      end

    end
  end
end
