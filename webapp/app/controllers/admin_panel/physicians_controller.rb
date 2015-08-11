module AdminPanel
  class PhysiciansController < BaseController
    before_action :set_physician, only: [:edit, :update, :destroy]

    def index
      @physicians = Physician.preload(:hospital, :department, :specialities)
      @physicians = @physicians.where('LOWER(physician_translations.name) LIKE LOWER(?)', "%#{params[:keyword]}%").with_translations if params[:keyword].present?
      if params[:vendor_id_from].present? && params[:vendor_id_to].present?
        @physicians.where!(vendor_id: params[:vendor_id_from]..params[:vendor_id_to])
      elsif params[:vendor_id_from].present? || params[:vendor_id_to].present?
        @physicians.where!(vendor_id: (params[:vendor_id_from].presence || params[:vendor_id_to].presence))
      end
      if [I18n.t('admin_panel.users.index.export_excel', locale: :en), I18n.t('admin_panel.users.index.export_excel', locale: :'zh-CN')].include?(params[:commit])
        headers['Content-Type'] = "application/vnd.ms-excel"
        headers['Content-Disposition'] = %~attachment; filename=Doctors_#{Time.now.to_s(:db)}.xls~
        headers['Cache-Control'] = ''
        render :export, layout: false
      else
        @physicians = @physicians.page(params[:page])
      end
    end

    def new
      @physician = Physician.new
    end

    def create
      @physician = Physician.new(physician_params)
      @physician.save
    end

    def update
      @physician.update(physician_params)
    end

    def destroy
      @physician.destroy
    end

    private
    def set_physician
      @physician = Physician.find(params[:id])
    end

    def physician_params
      params_data = params.require(:physician).permit(:name, :position, :birthdate, :gender, :hospital_id, :department_id, :first_speciality, :second_speciality, :third_speciality, :vendor_id, :first_speciality_id, :second_speciality_id, :third_speciality_id)

      if first_s = params_data[:first_speciality]
        params_data[:first_speciality] = Speciality.find_by(id: first_s)
      end
      if second_s = params_data[:second_speciality]
        params_data[:second_speciality] = Speciality.find_by(id: second_s)
      end
      if third_s = params_data[:third_speciality]
        params_data[:third_speciality] = Speciality.find_by(id: third_s)
      end
      params_data
    end
  end
end
