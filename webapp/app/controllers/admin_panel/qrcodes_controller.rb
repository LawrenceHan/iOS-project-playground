module AdminPanel
  class QrcodesController < BaseController
    before_action :set_qrcode, only: [:edit, :update]
    layout 'admin_panel', except: [:new, :edit]

    def index
      @qrcodes = Qrcode.page params[:page]
    end

    def new
      @qrcode = Qrcode.new
    end

    def create
      @qrcode = Qrcode.new(qrcode_params)
      @qrcode.save
    end

    def update
      @qrcode.update(qrcode_params)
    end

    private
    def set_qrcode
      @qrcode = Qrcode.find(params[:id])
    end

    def qrcode_params
      params.require(:qrcode).permit(:title, :url)
    end
  end
end
