module AdminPanel
  class MedicalExperiencesController < BaseController
    before_action :set_medical_experience, only: [:edit, :update, :destroy]
    layout 'admin_panel', except: [:edit, :show, :export]

    def export
      @medical_experiences = MedicalExperience.includes(:referral_code, :user, published_hospital_review: :hospital, published_physician_reviews: :physicians, published_medication_reviews: :medications).all
      headers['Content-Type'] = "application/vnd.ms-excel"
      headers['Content-Disposition'] = %~attachment; filename="medical_experiences_#{Time.now.to_s(:db)}.xls"~
      headers['Cache-Control'] = ''
    end

    def index
      @medical_experiences = MedicalExperience.includes(:referral_code, :user).page params[:page]
    end

    def update
      @medical_experience.update(medical_experience_params)
    end

    def destroy
      @medical_experience.destroy
    end

    def show
      @medical_experience = MedicalExperience.includes(:hospital_review, :physician_reviews, :medication_reviews, :hospital, :physicians, :medications).find(params[:id])
    end

    private
    def set_medical_experience
      @medical_experience = MedicalExperience.find(params[:id])
    end

    def medical_experience_params
      params.require(:medical_experience).permit(:user_id, :referral_code_id, :network_visible, :behalf, :completion, :avg_rating)
    end
  end
end
