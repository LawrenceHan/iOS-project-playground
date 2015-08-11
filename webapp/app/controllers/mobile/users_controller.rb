module Mobile
  class UsersController < BaseController
    def show
      @my_profile = false
      @user = User.find(params[:id])
      @profile = @user.profile.decorate
      @description_line = [@profile.gender, @profile.age].reject(&:blank?).join(' ')

      render 'mobile/my_accounts/show'
    end
  end
end
