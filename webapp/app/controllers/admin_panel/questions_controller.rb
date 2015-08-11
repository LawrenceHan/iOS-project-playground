module AdminPanel
  class QuestionsController < BaseController
    before_action :set_question, only: [:edit, :update, :destroy]
    layout 'admin_panel', except: [:new, :edit]

    def index
      @questions = Question.page params[:page]
    end

    def new
      @question = Question.new
    end

    def create
      @question = Question.new(question_params)
      @question.save
    end

    def update
      @question.update(question_params)
    end

    def destroy
      @question.destroy
    end

    private
    def set_question
      @question = Question.find(params[:id])
    end

    def question_params
      params.require(:question).permit(:category, :content)
    end
  end
end
