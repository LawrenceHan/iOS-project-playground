module Mobile
  class ProfilesController < BaseController
    def update
      # PATCH registrations/step_one
      # PATCH registrations/step_two
      # PATCH registrations/step_three
      @profile = Profile.find(params[:id])

      if @profile.update(profile_params)
        redirect_to next_step
      elsif %w(step_one step_two step_three).include?(params[:step])
        @css_namespace = 'registrations-controller'
        flash.now[:error] = @profile.errors.full_messages
        render "mobile/registrations/#{params[:step]}"
      end
    end

    private

    def profile_params
      params_data = params.require(:profile).permit(:username, :avatar, :gender, :birthdate, :height, :weight, :pathway, :occupation, :country, :city, :network_visible, :income_level, :condition_ids, :interests, :education_level, :region)
      params_data[:condition_ids].present? && params_data[:condition_ids] = params_data[:condition_ids].split(',').delete_if(&:blank?).uniq.map(&:to_i)
      params_data[:interests].present? && params_data[:interests] = params_data[:interests].split('#').delete_if(&:blank?).uniq
      params_data
    end

    def next_step
      case params[:step]
      when 'step_one'   then mobile_registrations_step_two_url
      when 'step_two'   then mobile_registrations_step_three_url
      when 'step_three' then mobile_my_account_url
      else                   mobile_registrations_step_one_url
      end
    end
  end
end

