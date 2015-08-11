module Survey
  class SurveysController < BaseController

    def show
      @survey = ::Survey::Survey.find_by uuid: params[:id]
      if @survey
        @survey_feedback = @survey.feedbacks.build
        questions = @survey.questions.order_by_position
        @questions_with_category = {}
        questions.uniq(&:category).map(&:category).each do |category|
          @questions_with_category[category] = questions.select { |question| question.category == category }
        end
        @tos = File.read Rails.root.join("app/views/api/pages/terms.#{@language}.html")
      else
        render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found
      end
    end
  end
end
