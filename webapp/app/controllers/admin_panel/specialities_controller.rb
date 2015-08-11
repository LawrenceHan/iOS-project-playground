module AdminPanel
  class SpecialitiesController < BaseController
    before_action :set_speciality, only: [:edit, :update, :destroy]
    layout 'admin_panel', except: [:new, :edit]

    def new
      @speciality = Speciality.new
    end

    def index
      @specialities = Speciality.all
      @specialities.where!('UPPER(specialities.name) LIKE UPPER(?)', "%#{params[:keyword]}%") if params[:keyword].present?
      if params[:vendor_id_from].present? && params[:vendor_id_to].present?
        @specialities.where!(vendor_id: (params[:vendor_id_from].to_i)..(params[:vendor_id_to]).to_i)
      elsif params[:vendor_id_from].present? || params[:vendor_id_to].present?
        @specialities.where!(vendor_id: (params[:vendor_id_from].presence || params[:vendor_id_to].presence).to_i)
      end
      if [I18n.t('admin_panel.users.index.export_excel', locale: :en), I18n.t('admin_panel.users.index.export_excel', locale: :'zh-CN')].include?(params[:commit])
        headers['Content-Type'] = "application/vnd.ms-excel"
        headers['Content-Disposition'] = %~attachment; filename=Specialities_#{Time.now.to_s(:db)}.xls~
        headers['Cache-Control'] = ''
        render :export, layout: false
      else
        @specialities = @specialities.page(params[:page])
      end
    end

    def create
      @speciality = Speciality.new(speciality_params)
      @speciality.save
    end

    def update
      @speciality.update(speciality_params)
    end

    def destroy
      @speciality.destroy
    end

    private
    def set_speciality
      @speciality = Speciality.find(params[:id])
    end

    def speciality_params
      params.require(:speciality).permit(:vendor_id, :name)
    end
  end
end
