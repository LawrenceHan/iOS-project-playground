module AdminPanel
  class SurveysController < BaseController
    before_action :set_survey, only: [:edit, :update, :destroy]
    layout 'admin_panel', except: [:new]

    def index
      @surveys = Survey::Survey.page params[:page]
    end

    def new
      @survey = Survey::Survey.new
    end

    def create
      if %(Survey::B2cSurvey Survey::B2bSurvey).include? params[:survey_survey][:type]
        @survey = Object.const_get(params[:survey_survey].delete(:type)).create(survey_params)
        @survey.init_survey
      end
    end

    def edit
      @survey.questions.build
    end

    def update
      @survey.update(survey_params)

      redirect_to action: :index
    end

    def destroy
      @survey.destroy
    end

    private

    def set_survey
      @survey = Survey::Survey.find(params[:id])
    end

    def survey_params
      if params[:survey_b2c_survey]
        params.require(:survey_b2c_survey)
      elsif params[:survey_b2b_survey]
        params.require(:survey_b2b_survey)
      else
        params.require(:survey_survey)
      end.permit(:title, :logo, :description, :note, :color, :questions_attributes => [:id, :title, :hint, :type, :default_value, :options, :category, :mandatory, :position, :_destroy])
    end
  end
end
