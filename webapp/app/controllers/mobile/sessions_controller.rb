class Mobile::SessionsController < Mobile::BaseController
  def new
  end

  def create
    @user = User.where(email: params[:user][:email]).first
    if @user
      if @user.authenticate(params[:user][:password])
        sign_in(@user)
        redirect_to after_sign_in_url
      else
        flash.now[:error] = I18n.t('signin.password_incorrect')
        render :new
      end
    else
      flash.now[:error] = I18n.t('signin.user_not_exist')
      render :new
    end
  end

  def destroy
    sign_out
    redirect_to after_sign_out_url
  end
end
