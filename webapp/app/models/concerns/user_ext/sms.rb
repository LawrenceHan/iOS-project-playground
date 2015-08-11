require 'httparty'

module UserExt
  module SMS
    extend ActiveSupport::Concern

    included do
      SMS_UID = APP_CONFIG[:sms][APP_CONFIG[:node].to_sym][:username]
      if APP_CONFIG[:node] == 'india'
        SMS_PWD = APP_CONFIG[:sms][:india][:password]
        SENDER_NAME = APP_CONFIG[:sms][:india][:sender_name]
      else
        SMS_PWD = Digest::MD5.hexdigest("#{APP_CONFIG[:sms][:china][:password]}#{APP_CONFIG[:sms][:china][:username]}")
      end

      attr_accessor :sms_token
      class_attribute :sms_validate_within, instance_writer: false
      self.sms_validate_within = 1.hour

      validates :sms_token, presence: { on: :create }, if: ->(u) { !u.is_guest }
    end

    module ClassMethods
      SMS_CHARS = ('0'..'9').to_a

      def generate_sms_token(size)
        (0...size).collect { SMS_CHARS[Kernel.rand(SMS_CHARS.length)] }.join
      end

      def send_validation_sms(sms_token, phone)
        content =
          if APP_CONFIG[:node] == 'india'
            "Your message authentication code: #{sms_token}. Sent by Carevoice."
          else
            if APP_CONFIG[:sms_provider]=='emay'
              "【康语】您的短信验证码是:#{sms_token}"
            else
              "您的短信验证码是:#{sms_token} 回复TD退订【康语发送】"
            end
          end

        send_sms(content, phone)
      end


      def send_sms(content, phone)
        return if content.blank? or phone.blank?

        content = CGI.escape(content)

        if APP_CONFIG[:node] == 'india'
          # TODO: extract to configuration file
          HTTParty.head "http://182.18.165.185/API/sms.php?username=#{SMS_UID}&password=#{SMS_PWD}&from=#{SENDER_NAME}&to=#{phone}&msg=#{content}&type=1&dnd_check=0"
        else
          if APP_CONFIG[:sms_provider]=='emay'
            # TODO: Ideally, this should be in a config file.
            emay_cdkey = APP_CONFIG[:emay_key]
            emay_password = APP_CONFIG[:emay_password]

            auth_string = "cdkey=#{emay_cdkey}&password=#{emay_password}"
            # Seems like the registration request isn't necessary.
            #HTTParty.head "http://sdk4report.eucp.b2m.cn:8080/sdkproxy/regist.action?#{auth_string}"
            # TODO: https support for these services?
            HTTParty.head "http://sdk4report.eucp.b2m.cn:8080/sdkproxy/sendsms.action?#{auth_string}&phone=#{phone}&message=#{content}"
          else
            HTTParty.head "http://api.sms7.com.cn/mt/?uid=#{SMS_UID}&pwd=#{SMS_PWD}&mobile=#{phone}&mobileids=#{phone}&content=#{content}&encode=utf8"
          end
        end
      end
    end

    def sms_token_match_with(phone_num, token)
      return true if APP_CONFIG[:sms][:test_mode]
      self.errors.add(:phone) unless self.phone == phone_num
      self.errors.add(:sms_token, I18n.t('word.not_match')) if token.blank? || self.sms_token != token
    end
  end
end
