module Mobile
  class FeedbackController < BaseController
    before_filter :authenticate_user!
    skip_before_filter :verify_authenticity_token, only: :create

    def new
      @feedback = Feedback.new
    end

    def create
      @feedback = current_user.feedback.new(params.require(:feedback).permit(:content))
      @feedback.save
    end
  end
end
