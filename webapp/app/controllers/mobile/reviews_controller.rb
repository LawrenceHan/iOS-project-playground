module Mobile
  class ReviewsController < BaseController

    REVIEW_ATTRS = [:note, { answers_attributes: [:question_id, :waiting_time, :price, :rating] }]
    MEDICATION_REVIEW_ATTRS = REVIEW_ATTRS + [:dosage_count, :dosage_unit, :intake_frequency, :duration_count, :duration_unit]

    before_action :authenticate_user_or_guest!, only: [:new, :create]
    before_action :guest_can_have_only_one_medical_experience!, only: [:new, :create]

    def index
      if params[:hospital_id]
        @scope = @hospital = Hospital.find(params[:hospital_id])
      elsif params[:physician_id]
        @scope = @physician = Physician.find(params[:physician_id])
      elsif params[:medication_id]
        @scope = @medication = Medication.find(params[:medication_id])
      elsif params[:user_id]
        @scope = User.find(params[:user_id])
        params[:type] ||= 'hospital'
      else
        raise AbstractController::ActionNotFound
      end

      @reviews = @scope.reviews.published.order('updated_at DESC').page(params[:page])

      if %w(hospital physician medication).include?(params[:type])
        @reviews.where!(type: params[:type].capitalize + 'Review')
        @reviews.includes!(params[:type].to_sym)
      end

      render 'mobile/search/review'
    end

    def show
      @review = Review.includes(:profile, :questions).find(params[:id])
      @answers = @review.answers.includes(:question).where("questions.question_type = ?", 'rating').references(:questions)
      total_answers_count = @answers.count

      unless params[:with_optional].present?
        @has_more = (@answers.count != total_answers_count)
      end

      # First display compulsory, then optionals
      @review.current_user = current_user
    end

    def new
      session.delete :current_medical_experience_id if params[:new_medical_experience]

      if params[:hospital_id]
        @questions = Question.hospital_questions
        @reviewable = @hospital = Hospital.find(params[:hospital_id])
        @review = @hospital.hospital_reviews.build
      elsif params[:physician_id]
        @questions = Question.physician_questions
        @reviewable = @physician = Physician.find(params[:physician_id])
        @review = @physician.physician_reviews.build
      elsif params[:medication_id]
        @questions = Question.medication_questions
        @reviewable = @medication = Medication.find(params[:medication_id])
        @review = @medication.medication_reviews.build
      else
        raise AbstractController::ActionNotFound
      end
    end

    def create
      if params[:hospital_id]
        @questions = Question.hospital_questions
        @reviewable = @hospital = Hospital.find(params[:hospital_id])
        @review = @hospital.hospital_reviews.build(
          params.require(:review).permit(REVIEW_ATTRS)
        )
      elsif params[:physician_id]
        @questions = Question.physician_questions
        @reviewable = @physician = Physician.find(params[:physician_id])
        @review = @physician.physician_reviews.build(
          params.require(:review).permit(REVIEW_ATTRS)
        )
      elsif params[:medication_id]
        @questions = Question.medication_questions
        @reviewable = @medication = Medication.find(params[:medication_id])
        @review = @medication.medication_reviews.build(
          params.require(:review).permit(MEDICATION_REVIEW_ATTRS)
        )
      else
        raise AbstractController::ActionNotFound
      end

      if !session[:current_medical_experience_id]
        me = MedicalExperience.create(user: current_user_or_guest)
        session[:current_medical_experience_id] = me.id
      end

      @review.medical_experience_id = session[:current_medical_experience_id]

      if @review.save
        redirect_to edit_mobile_medical_experience_path(@review.medical_experience_id)
      else
        flash.now[:error] = @review.errors.full_messages
        render :new
      end
    end

    def destroy
      @review = Review.find(params[:id])
      @review.destroy!
      redirect_to :back
    end

    protected
    def required_questions
      @required_questions ||= @questions
    end

    def optional_questions
      @optional_questions ||= []
    end

    helper_method :required_questions, :optional_questions

  end
end
