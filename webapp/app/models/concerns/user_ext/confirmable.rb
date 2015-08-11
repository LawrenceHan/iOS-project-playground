module UserExt
  module Confirmable
    extend ActiveSupport::Concern
    include Utils

    included do
      class_attribute :confirm_within, instance_writer: false
      self.confirm_within = 3.days

      # before_create :generate_confirmation_token
      # after_create :send_confirmation_instructions, if: ->(x) { !x.skip_confirmation }
      # before_update :postpone_email_change_until_confirmation_and_regenerate_confirmation_token, if: :postpone_email_change?
      # after_update :resend_confirmation_instructions, if: :reconfirmation_required?
    end

    def initialize(*args, &block)
      @bypass_confirmation_postpone = false
      @reconfirmation_required = false
      super
    end

    def confirmed?
      !!confirmed_at
    end

    def pending_reconfirmation?
      unconfirmed_email.present?
    end

    def send_confirmation_instructions
      generate_confirmation_token! unless self.confirmation_token?
      sending_email = unconfirmed_email.presence || email
      UserMailer.confirm_email(sending_email, self.confirmation_token).deliver
    end

    def resend_confirmation_instructions
      @reconfirmation_required = false
      pending_any_confirmation do
        send_confirmation_instructions
      end
    end

    def confirm!
      pending_any_confirmation do
        if confirmation_period_expired?
          self.errors.add(:confirmation_token, I18n.t('api.confirmation.token_expired'))
          return false
        end
        if pending_reconfirmation?
          @bypass_confirmation_postpone = true
          self.email = unconfirmed_email
          self.unconfirmed_email = nil
        end

        self.confirm
        self.save(validate: true)
      end
    end

    def confirm
      self.confirmation_token = nil
      self.confirmed_at = Time.now.utc
    end

    def generate_confirmation_token
      loop do
        token = generate_token
        unless self.class.where(confirmation_token: token).any?
          self.confirmation_token = token
          self.confirmation_sent_at = Time.now.utc
          break
        end
      end
    end

    def generate_confirmation_token!
      generate_confirmation_token && save(validate: false)
    end

    protected
    def postpone_email_change_until_confirmation_and_regenerate_confirmation_token
      @reconfirmation_required = true
      self.unconfirmed_email = self.email
      self.email = self.email_was
      generate_confirmation_token
    end

    def postpone_email_change?
      postpone = email_changed? && !@bypass_confirmation_postpone && !self.email.blank?
      @bypass_confirmation_postpone = false
      postpone
    end

    def confirmation_period_expired?
      self.confirm_within && (Time.now > self.confirmation_sent_at + self.confirm_within )
    end

    def reconfirmation_required?
      @reconfirmation_required && self.email.present?
    end

    def pending_any_confirmation
      if (!confirmed? || pending_reconfirmation?)
        yield
      else
        self.errors.add(:email, I18n.t('api.confirmation.already_confirmed'))
        false
      end
    end
  end
end
