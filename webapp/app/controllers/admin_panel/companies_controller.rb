module AdminPanel
  class CompaniesController < BaseController
    before_action :set_company, only: [:edit, :update, :destroy]

    def index
      @companies = Company.all
      @companies.where!('UPPER(cn_name) LIKE UPPER(:keyword) OR UPPER(en_name) LIKE UPPER(:keyword)', keyword: "%#{params[:keyword]}%") if params[:keyword].present?
      if params[:vendor_id_from].present? && params[:vendor_id_to].present?
        @companies.where!(vendor_id: (params[:vendor_id_from].to_i)..(params[:vendor_id_to]).to_i)
      elsif params[:vendor_id_from].present? || params[:vendor_id_to].present?
        @companies.where!(vendor_id: (params[:vendor_id_from].presence || params[:vendor_id_to].presence).to_i)
      end
      if params[:commit] == t('admin_panel.users.index.export_excel')
        headers['Content-Type'] = "application/vnd.ms-excel"
        headers['Content-Disposition'] = %~attachment; filename=Manufacturers_#{Time.now.to_s(:db)}.xls~
        headers['Cache-Control'] = ''
        render :export, layout: false
      else
        @companies = @companies.page(params[:page])
      end
    end

    def new
      @company = Company.new
    end

    def create
      @company = Company.new(company_params)
      @company.save
    end

    def update
      @company.update(company_params)
    end

    def destroy
      @company.destroy
    end

    private
    def set_company
      @company = Company.find(params[:id])
    end

    def company_params
      params.require(:company).permit(:vendor_id, :en_name, :cn_name)
    end
  end
end
