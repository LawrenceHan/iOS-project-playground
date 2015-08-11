module AdminPanel
  class SymptomsController < BaseController
    before_action :set_symptom, only: [:edit, :update, :destroy]
    layout 'admin_panel', except: [:new, :edit]

    def index
      @symptoms = Symptom.page params[:page]
    end

    def new
      @symptom = Symptom.new
    end

    def create
      @symptom = Symptom.new(symptom_params)
      @symptom.save
    end

    def update
      @symptom.update(symptom_params)
    end

    def destroy
      @symptom.destroy
    end

    private
    def set_symptom
      @symptom = Symptom.find(params[:id])
    end

    def symptom_params
      params.require(:symptom).permit(:name, :category)
    end
  end
end
