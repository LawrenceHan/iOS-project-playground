module AdminPanel
  class ReviewsController < BaseController
    before_action :set_review, only: [:show, :destroy, :audit, :preview, :edit, :update]
    before_action :set_reviews, only: [:export, :index]
    layout 'admin_panel', except: [:show, :preview, :edit]

    def export
      @questions = @klass.questions.pluck(:content)
      headers['Content-Type'] = "application/vnd.ms-excel"
      headers['Content-Disposition'] = %~attachment; filename="#{@klass.model_name.plural}_#{Time.now.to_s(:db)}.xls"~
      headers['Cache-Control'] = ''
      render layout: false
    end

    def index
      @reviews = @reviews.page params[:page]
      @reviews.where!("users.phone = ?", params[:phone]).references!(:users) if params[:phone].present?
    end

    def update
      status = review_params.delete(:status)
      @review.update(review_params)

      # status updated automatically in model callback, so here must update by hand
      @review.update_columns(status: status) if Review::STATUS.include?(status)
    end

    def destroy
      @review.destroy
    end

    def audit
      @review.update(status: params[:as])
    end

    private
    def set_review
      @review = Review.find(params[:id])
    end

    def set_reviews
      @klass = (params[:type].presence || 'Review').classify.constantize
      @reviews = @klass.includes(:user, :medical_experience, {answers: :question})
      from = (DateTime.parse(params[:start]) rescue nil)
      to = (DateTime.parse(params[:end]) rescue nil)
      if from && to
        @reviews = @reviews.where(created_at: from..to)
      end
      case params[:type]
      when 'HospitalReview'   then @reviews.includes!(:hospital)
      when 'PhysicianReview'  then @reviews.includes!({physician: :hospital}, :specialities)
      when 'MedicationReview' then @reviews.includes!(:medication)
      end
    end

    def review_params
      params.require(:review).permit!
    end
  end
end
