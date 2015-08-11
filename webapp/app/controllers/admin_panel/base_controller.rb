module AdminPanel
  class BaseController < ApplicationController
    before_action :require_admin!
    before_action :set_locale

    prepend_view_path Rails.root.join('app', 'views', 'admin_panel')

    layout 'admin_panel', except: [:new, :edit]

    private
    def set_locale
      I18n.locale = params[:locale].presence || I18n.default_locale# || extract_locale_from_accept_language_header
    end

    def extract_locale_from_accept_language_header
      request.env['HTTP_ACCEPT_LANGUAGE'].split(",").first.strip
    end
  end
end
