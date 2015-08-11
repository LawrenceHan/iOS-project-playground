module Mobile
  class GuestFlowController < BaseController

    def index
      if params[:clear_me] and guest_signed_in?
        current_guest.medical_experiences.destroy_all
      end

      logger.debug "   * Guest user: #{current_guest.inspect}"
      if current_guest 
        @medical_experience = current_guest.medical_experiences.first
      end
    end


    def start_medical_experience
      sign_out
      sign_in(User.create_guest, scope: :guest) unless current_guest
      redirect_to new_mobile_medical_experience_path
    end

  end
end
