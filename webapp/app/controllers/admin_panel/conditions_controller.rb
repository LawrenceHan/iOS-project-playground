module AdminPanel
  class ConditionsController < BaseController
    before_action :set_condition, only: [:edit, :update, :destroy]
    layout 'admin_panel', except: [:new, :edit]

    def index
      @conditions = Condition.page params[:page]
    end

    def new
      @condition = Condition.new
    end

    def create
      @condition = Condition.new(condition_params)
      @condition.save
    end

    def update
      @condition.update(condition_params)
    end

    def destroy
      @condition.destroy
    end

    private
    def set_condition
      @condition = Condition.find(params[:id])
    end

    def condition_params
      params.require(:condition).permit(:name, :category)
    end
  end
end
