module AdminPanel
  class FeedbackController < BaseController
    before_action :set_feedback, only: :destroy

    def index
      @feedback = Feedback.includes(:user).page params[:page]
    end

    def destroy
      @feedback.destroy
    end

    private
    def set_feedback
      @feedback = Feedback.find(params[:id])
    end
  end
end
