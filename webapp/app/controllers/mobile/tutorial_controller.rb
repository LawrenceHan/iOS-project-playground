module Mobile
  class TutorialController < BaseController
    def intro
      redirect_to mobile_my_account_path if cookies[:first_run_at] and !params[:show_intro]
      cookies[:first_run_at] = { value: Time.now, expires: 10.years.from_now } if params[:step] == 'two'
    end
  end
end
