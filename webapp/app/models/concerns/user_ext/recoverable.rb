module UserExt
  # Recoverable takes care of resetting the user password and send reset instructions.
  #
  # ==Options
  #
  # Recoverable adds the following options to devise_for:
  #
  #   * +reset_password_keys+: the keys you want to use when recovering the password for an account
  #
  # == Examples
  #
  #   # resets the user password and save the record, true if valid passwords are given, otherwise false
  #   User.find(1).reset_password!('password123', 'password123')
  #
  #   # only resets the user password, without saving the record
  #   user = User.find(1)
  #   user.reset_password('password123', 'password123')
  #
  #   # creates a new token and send it with instructions about how to reset the password
  #   User.find(1).reset_password
  #
  module Recoverable
    extend ActiveSupport::Concern
    include Utils
    include Rails.application.routes.url_helpers

    included do
      class_attribute :reset_password_within, instance_writer: false
      self.reset_password_within = 24.hours
    end

    # Update password saving the record and clearing token. Returns true if
    # the passwords are valid and the record was saved, false otherwise.
    def reset_password!(new_password, new_password_confirmation)
      self.password = new_password
      self.password_confirmation = new_password_confirmation

      if valid?
        clear_reset_password_token
      end

      save
    end

    # Resets reset password token and send reset password instructions by email.
    # Returns the token sent in the e-mail.
    def send_reset_password_instructions
      self.reset_password_token   = generate_token
      self.reset_password_sent_at = Time.now.utc
      self.save(:validate => false)

      UserMailer.reset_password(self.email, self.reset_password_token).deliver
    end

    def send_reset_password_instructions_via_sms
      self.reset_password_token   = generate_token
      self.reset_password_sent_at = Time.now.utc
      self.save(:validate => false)

      host = APP_CONFIG[:protocol] + APP_CONFIG[:host]
      link = api_edit_password_url(reset_password_token: self.reset_password_token, host: host, locale: I18n.locale)
      msg = I18n.t('api.password.sms_reset_message', link: link, time: I18n.l(Time.now, format: :long))

      send_sms(msg)
    end

    def send_sms(msg)
      self.class.send_sms(msg, phone)
    end

    # Checks if the reset password token sent is within the limit time.
    # We do this by calculating if the difference between today and the
    # sending date does not exceed the confirm in time configured.
    # Returns true if the resource is not responding to reset_password_sent_at at all.
    # reset_password_within is a model configuration, must always be an integer value.
    #
    # Example:
    #
    #   # reset_password_within = 1.day and reset_password_sent_at = today
    #   reset_password_period_valid?   # returns true
    #
    #   # reset_password_within = 5.days and reset_password_sent_at = 4.days.ago
    #   reset_password_period_valid?   # returns true
    #
    #   # reset_password_within = 5.days and reset_password_sent_at = 5.days.ago
    #   reset_password_period_valid?   # returns false
    #
    #   # reset_password_within = 0.days
    #   reset_password_period_valid?   # will always return false
    #
    def reset_password_period_valid?
      reset_password_sent_at && reset_password_sent_at.utc >= self.class.reset_password_within.ago
    end

    protected

    # Removes reset_password token
    def clear_reset_password_token
      self.reset_password_token = nil
      self.reset_password_sent_at = nil
    end

    module ClassMethods
      # Attempt to find a user by its email. If a record is found, send new
      # password instructions to it. If user is not found, returns a new user
      # with an email not found error.
      # Attributes must contain the user's email
      def send_reset_password_instructions(attributes={})
        user = where(email: attributes[:email]).first_or_initialize
        user.errors.add(:email, I18n.t('word.not_found')) unless user.persisted?
        user.send_reset_password_instructions if user.persisted?
        user
      end



      # Attempt to find a user by its reset_password_token to reset its
      # password. If a user is found and token is still valid, reset its password and automatically
      # try saving the record. If not user is found, returns a new user
      # containing an error in reset_password_token attribute.
      # Attributes must contain reset_password_token, password and confirmation
      def reset_password_by_token(attributes={})
        user = where(reset_password_token: attributes[:reset_password_token]).first_or_initialize
        user.errors.add(:reset_password_token, I18n.t('word.not_found')) unless user.persisted?

        if user.persisted?
          if user.reset_password_period_valid?
            user.reset_password!(attributes[:password], attributes[:password_confirmation])
          else
            user.errors.add(:reset_password_token, I18n.t('api.password.token_expired'))
          end
        end
        user
      end
    end
  end
end
