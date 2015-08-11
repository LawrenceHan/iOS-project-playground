module API
  class ConfirmationController < Base

    def confirm
      if user = User.find_by(confirmation_token: params[:confirmation_token])
        user.confirm!
        @message = '确认账号成功了！'
      else
        @message = '链接已过期，请重新发送确认邮件！'
      end
      render "confirmation/confirm"
    end

  end
end
