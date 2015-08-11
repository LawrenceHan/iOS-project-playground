module AdminPanel
  class DepartmentsController < BaseController
    before_action :set_department, only: [:edit, :update, :destroy]

    def index
      @departments = Department.all
      @departments.joins!(:hospitals).where!(hospitals: { id: params[:hospital_id]}) if params[:hospital_id].present?
      if params[:export] == 'true'
        headers['Content-Type'] = "application/vnd.ms-excel"
        headers['Content-Disposition'] = %~attachment; filename=Departments_#{Time.now.to_s(:db)}.xls~
        headers['Cache-Control'] = ''
        render :export, layout: false
      else
        if request.xhr?
          render layout: false
        else
          @departments = @departments.page(params[:page])
        end
      end
    end

    def new
      @department = Department.new
    end

    def create
      @department = Department.new(department_params)
      @department.save
    end

    def update
      @department.update(department_params)
    end

    def destroy
      @department.destroy
    end

    private
    def set_department
      @department = Department.find(params[:id])
    end

    def department_params
      params.require(:department).permit(:vendor_id, :name, :position, :birthdate, :gender)
    end
  end
end
