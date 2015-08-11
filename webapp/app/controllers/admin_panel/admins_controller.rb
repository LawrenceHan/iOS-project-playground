module AdminPanel
  class AdminsController < BaseController
    before_action :set_admin, only: [:edit, :update, :destroy]

    def index
      @admins = Admin.page params[:page]
      # FIXME: move to qrcodes controller
      @qrcodes = Qrcode.all
    end

    def new
      @admin = Admin.new
    end

    def create
      @admin = Admin.new(admin_params)
      @admin.save
    end

    def update
      @admin.update(admin_params)
    end

    def destroy
      @admin.destroy
    end

    private
    def set_admin
      @admin = Admin.find(params[:id])
    end

    def admin_params
      params.require(:admin).permit(:email, :password, :password_confirmation)
    end
  end
end
