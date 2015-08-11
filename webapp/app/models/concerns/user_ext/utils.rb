module UserExt
  module Utils
    extend ActiveSupport::Concern

    included do
      HMAC_KEY = '98C53HZXbhEI4[f.'
    end

    module ClassMethods
      def generate_token
        OpenSSL::HMAC.hexdigest('SHA256', HMAC_KEY, friendly_token)
      end

      def friendly_token
        SecureRandom.urlsafe_base64(15).tr('lIO0', 'sxyz')
      end
    end


    # Generate a token
    def generate_token
      self.class.generate_token
    end

    # Generate a friendly string randomly to be used as token.
    def friendly_token
      self.class.friendly_token
    end

  end
end