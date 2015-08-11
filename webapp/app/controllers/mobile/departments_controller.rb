module Mobile
  class DepartmentsController < BaseController
    def index
      @hospital = Hospital.find(params[:hospital_id])
      @departments = @hospital.departments.order('name')
      @physicians_counts_hash = @hospital.departments.joins(:physicians).group('departments.id').where(['physicians.hospital_id = ?', @hospital.id]).count('physicians.id')
    end
  end
end
