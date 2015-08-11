module AdminPanel
  class AuthenticationsController < BaseController
    before_action :set_authentication, only: :show
    layout 'admin_panel', except: [:show]

    def index
      @authentications = Authentication.includes(:user).page params[:page]
    end

    private
    def set_authentication
      @authentication = Authentication.find(params[:id])
    end
  end
end
