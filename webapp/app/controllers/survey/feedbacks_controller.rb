module Survey
  class FeedbacksController < BaseController

    def create
      @survey = ::Survey::Survey.find_by uuid: params[:survey_id]
      @feedback = @survey.feedbacks.build survey_feedback_params
      if @feedback.save
        redirect_to success_survey_path(@survey)
      else
        render survey_path(@survey)
      end
    end

    protected

    def survey_feedback_params
      params.require(:survey_feedback).permit(:display_medical_feedback, :receive_information, answers_attributes: [ :question_id, :value, :other_value ])
    end
  end
end
