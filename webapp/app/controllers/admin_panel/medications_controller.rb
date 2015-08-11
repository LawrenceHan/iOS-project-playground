module AdminPanel
  class MedicationsController < BaseController
    before_action :set_medication, only: [:edit, :update, :destroy]

    def index
      @medications = Medication.includes(:first_company)
      @medications.where!('UPPER(name) LIKE UPPER(?)', "%#{params[:keyword]}%") if params[:keyword].present?
      if params[:vendor_id_from].present? && params[:vendor_id_to].present?
        @medications.where!(vendor_id: (params[:vendor_id_from].to_i)..(params[:vendor_id_to]).to_i)
      elsif params[:vendor_id_from].present? || params[:vendor_id_to].present?
        @medications.where!(vendor_id: (params[:vendor_id_from].presence || params[:vendor_id_to].presence).to_i)
      end
      if [I18n.t('admin_panel.users.index.export_excel', locale: :en), I18n.t('admin_panel.users.index.export_excel', locale: :'zh-CN')].include?(params[:commit])
        headers['Content-Type'] = "application/vnd.ms-excel"
        headers['Content-Disposition'] = %~attachment; filename=Medications_#{Time.now.to_s(:db)}.csv~
        headers['Cache-Control'] = ''

        string = "Vendor ID, Name, Average rating, Company Vendor ID\n"

        @medications.each_with_index do |medication, index|
          string << "#{medication.vendor_id},#{medication.name.inspect},#{medication.avg_rating},#{medication.first_company.try(:vendor_id)}\n"
        end

        render :text => string
      else
        @medications = @medications.page(params[:page])
      end
    end

    def new
      @medication = Medication.new
    end

    def create
      @medication = Medication.new(medication_params)
      @medication.save
    end

    def update
      @medication.update(medication_params)
    end

    def destroy
      @medication.destroy
    end

    private
    def set_medication
      @medication = Medication.find(params[:id])
    end

    def medication_params
      params.require(:medication).permit(:name, :code, :dosage1, :dosage2, :dosage3, :vendor_id, :first_company_id)
    end
  end
end
