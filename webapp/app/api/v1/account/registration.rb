module V1::Account
  module Registration
    class API < Grape::API

      helpers AuthorizeHelper

      resource :register do
        desc 'Ask for SMS validation sending'
        params do
          requires :phone, type: String, desc: 'Phone number'
        end
        post :sms_sending do
          return say_succeed if session[:sms_send_at] && (Time.now - session[:sms_send_at] < 120)
          return say_failed I18n.t('api.registration.sms.already_used') if User.exists?(phone: params[:phone])
          if !APP_CONFIG[:sms][:test_mode]
            session[:phone] = params[:phone]
            session[:sms_token] ||= User.generate_sms_token(6)
            session[:sms_send_at] = Time.now
            User.send_validation_sms(session[:sms_token], params[:phone])
          else
            Rails.logger.debug "SMS test mode is on, skipping sending the token"
          end

          say_succeed
        end

        desc 'User Registration'
        params do
          requires :user, type: Hash do
            requires :email, type: String, desc: 'Email'
            requires :password, type: String, desc: 'Password'
            requires :phone, type: String, desc: 'Phone number'
            requires :sms_token, type: String, desc: 'Sms validate token'
          end
        end
        post do
          # Make sure SMS token not expired
          if session[:sms_send_at].present? and
            (Time.now > session[:sms_send_at] + User.sms_validate_within) and
            !APP_CONFIG[:sms][:test_mode]
            return say_failed I18n.t('api.registration.sms.token_expired')
          end
          user = User.new(get_params_data(:user, [:email, :password, :phone, :sms_token]))
          if session[:phone] && session[:sms_token]
            user.sms_token_match_with(session[:phone], session[:sms_token])
          else
            user.sms_token_match_with(params[:user][:phone], $redis.get(params[:user][:phone]))
          end

          # Skip confirmation
          user.skip_confirmation = true
          user.confirm

          if user.errors.empty? && user.save
            session[:phone] = nil
            session[:sms_token] = nil
            session[:sms_send_at] = nil
            $redis.del(params[:user][:phone])
            warden.set_user(user)
            say_succeed user.as_json(only: [:email, :phone], methods: :username)
          else
            say_failed user
          end
        end
      end
    end
  end
end
