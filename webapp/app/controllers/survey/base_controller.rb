module Survey
  class BaseController < ApplicationController
    layout 'survey'

    skip_around_action :set_current_user_id
    before_action :set_locale
    before_action :set_language

  protected

    def set_locale
      I18n.locale = params[:locale] || extract_locale_from_accept_language_header || I18n.default_locale
    end

    def set_language
      @language = I18n.locale.to_s.split('-').first
      if @language != 'zh'
        @language = 'en'
        I18n.locale = 'en'
      end
    end

    def extract_locale_from_accept_language_header
      request.env['HTTP_ACCEPT_LANGUAGE']
    end
  end
end
