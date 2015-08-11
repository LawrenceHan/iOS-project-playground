require 'grape-swagger'

module V2
  module CV
    class API < Grape::API
      format :json
      rescue_from :all do |e|
        if API.should_notify(e)
          if ExceptionNotifier.notify_exception(e, env: env)
            env['exception_notifier.delivered'] = true
          else
            Rails.logger.fatal '*' * 40
            Rails.logger.fatal 'Notify exception failed'
            Rails.logger.fatal '*' * 40
          end
        end

        error_message = Grape::Exceptions::ValidationErrors === e ? I18n.t('api.server_error.validation_error') : I18n.t('api.server_error.normal')

        Rails.logger.fatal e.inspect + "\n" + e.backtrace.map { |line| "  " + line }.join("\n")
        Rack::Response.new([ { error: error_message }.to_json ], 500, { "Content-type" => "application/json" }).finish
      end

      # Fix I18n BUG
      before do
        I18n.locale = params[:locale].presence || I18n.default_locale
      end

      # Set current user id
      before do
        User.current_user_id = (defined?(current_user) ? current_user.try(:id) : nil)
      end

      # Set current user to nil after the request is processed
      after do
        User.current_user_id = nil
      end

      mount V2::Account::API
      mount V2::Reviews::API
      mount V2::Hospitals::API
      mount V2::Physicians::API
      mount V2::Medications::API
      mount V1::FeedbackApi::API
      mount V2::Search::API
      mount V2::Conversations::API
      mount V2::Administrator::API
      mount V2::Surveys::API

      add_swagger_documentation api_version: 'v2', hide_documentation_path: true, base_path: '/v2'

      def self.should_notify(e)
        case e
        when Grape::Exceptions::ValidationErrors
          false
        else
          true
        end
      end
    end
  end
end
