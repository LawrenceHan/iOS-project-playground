class QrcodesController < ApplicationController
  skip_around_filter :set_current_user_id

  def show
    qrcode = Qrcode.find params[:id]
    qrcode.increment! :count
    redirect_to qrcode.url
  end
end
