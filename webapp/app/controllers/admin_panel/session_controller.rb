module AdminPanel
  class SessionController < BaseController
    skip_before_action :require_admin!
    before_action :require_logout!, only: :new
    layout false

    def create
      admin = Admin.find_by(email: params[:email])
      if admin && admin.authenticate(params[:password])
        login!(admin)
        redirect_to dashboard_path
      else
        flash.now.alert = 'Email or password not matched!'
        render :new
      end
    end

    def destroy
      logout!
      redirect_to root_url
    end

    private
    def login!(admin)
      session[:admin_id] = admin.id
      remember_me!
    end

    def remember_me!
      cookies.signed[:admin_id] = { value: session[:admin_id], expires: 7.days.from_now } if params[:remember_me]
    end

    def logout!
      reset_session
      cookies.delete :admin_id
    end
  end
end
