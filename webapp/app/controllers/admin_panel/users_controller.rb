module AdminPanel
  class UsersController < BaseController
    before_action :set_user, only: [:destroy, :profile]
    layout 'admin_panel', except: [:profile, :export, :new]

    def index
      @users = User.includes(:weibo_auth, :tqq_auth, :profile).order('users.id desc').page params[:page]
      if params[:id].present?
        @users.where!("users.id = :id", id: params[:id])
      elsif params[:profile_id].present?
        @users.where!("profiles.id = :id", id: params[:profile_id]).references!(:profile)
      elsif params[:keyword].present?
        @users.where!('UPPER(profiles.username) LIKE UPPER(:keyword) OR UPPER(users.email) LIKE UPPER(:keyword) OR users.phone LIKE :keyword', keyword: "%#{params[:keyword]}%").references!(:profile)
      end
      @users
    end

    def new
      @user = User.new profile: Profile.new
    end

    def create
      @user = User.new user_params
      @user.sms_token = User.generate_sms_token(6)
      @user.password_confirmation = @user.password
      if @user.save
        @user.profile.update_attributes profile_params[:profile]
      end
    end

    def destroy
      @user.destroy
    end

    def profile
      @profile = @user.profile
    end

    def export
      @users = User.includes(:profile, :published_reviews).all
      headers['Content-Type'] = "application/vnd.ms-excel"
      headers['Content-Disposition'] = %~attachment; filename="Users_#{Time.now.to_s(:db)}.xls"~
      headers['Cache-Control'] = ''
    end

    def login_as
      user = User.find(params[:id])
      warden.set_user(user)
      name = user.profile.try(:username) || user.email
      flash[:notice] = "Successfully logged in as #{name}"
      redirect_to request.referer
    end

    private
    def set_user
      @user = User.find(params[:id])
    end

    def profile_params
      params.require(:user).permit(profile: [:avatar, :country, :city, :username])
    end

    def user_params
      params.require(:user).permit(:phone, :password, :username)
    end
  end
end
