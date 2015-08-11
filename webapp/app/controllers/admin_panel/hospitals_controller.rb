module AdminPanel
  class HospitalsController < BaseController
    before_action :set_hospital, only: [:edit, :update, :destroy]
    skip_before_filter :verify_authenticity_token, :only => :update_geocoding
    respond_to :html, :json, :js

    layout 'admin_panel', except: [:new, :edit, :physicians, :map]

    def index
      @hospitals = Hospital.includes(:departments).order(updated_at: :desc)
      @hospitals = @hospitals.reorder!("h_class_order(h_class) #{params[:h_class_order]}") if params[:h_class_order]
      @hospitals = @hospitals.where('LOWER(hospital_translations.name) LIKE LOWER(?)', "%#{params[:keyword]}%").with_translations if params[:keyword].present?
      @hospitals.where!(latitude: params[:lat]) if params[:lat].present?
      @hospitals.where!(latitude: params[:lng]) if params[:lng].present?
      if params[:vendor_id_from].present? && params[:vendor_id_to].present?
        vendor_id_range = (APP_CONFIG[:node] == "india" ? ((params[:vendor_id_from].to_i)..(params[:vendor_id_to]).to_i).map(&:to_s) : params[:vendor_id_from]..params[:vendor_id_to])
        @hospitals.where!(vendor_id: vendor_id_range)
      elsif params[:vendor_id_from].present? || params[:vendor_id_to].present?
        @hospitals.where!(vendor_id: (params[:vendor_id_from].presence || params[:vendor_id_to].presence))
      end
      if [I18n.t('admin_panel.users.index.export_excel', locale: :en), I18n.t('admin_panel.users.index.export_excel', locale: :'zh-CN')].include?(params[:commit])
        @hospitals = @hospitals.includes(:physicians)
        headers['Content-Type'] = "application/vnd.ms-excel"
        headers['Content-Disposition'] = %~attachment; filename=Hospitals_#{Time.now.to_s(:db)}.xls~
        headers['Cache-Control'] = ''
        render :export, layout: false
      else
        @hospitals = @hospitals.page(params[:page])
      end
    end

    def export

    end

    def new
      @hospital = Hospital.new
    end

    def create
      @hospital = Hospital.new(hospital_params)
      @hospital.save
    end

    def update
      @hospital.update(hospital_params)

      respond_with @hospital
    end

    def destroy
      @hospital.destroy
    end

    def physicians
      @physicians = Physician.includes(:department, :specialities).where(hospital_id: params[:id])
    end

    def departments
      @hospital = Hospital.find(params[:id])
      render json: {name: @hospital.name, departments: @hospital.departments.pluck(:vendor_id, :name, :id) }
    end

    def map
      @hospital = Hospital.find_by(id: params[:id])
      @zoom = 18
      @lat = @hospital.latitude.to_f
      @lng = @hospital.longitude.to_f

      # Use Shanghai lat and lng
      if @lat.zero? or @lng.zero?
        @zoom = 12
        @lat = 31.235380803488
        @lng = 121.454755557
      end
    end

    def update_geocoding
      @hospital = Hospital.find(params[:id])
      @hospital.update(params.require(:hospital).permit(:latitude, :longitude))
      render json: { success: @hospital.errors.empty?, message: @hospital.errors.full_messages.join("\n") }
    end

    private
    def set_hospital
      @hospital = Hospital.find(params[:id])
    end

    def hospital_params
      params.require(:hospital).permit(:name, :vendor_id, :official_name, :phone, :address, :post_code, :h_class, :ownership, {department_ids: []})
    end
  end
end
