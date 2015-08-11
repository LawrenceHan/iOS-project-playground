module AdminPanel
  class ReportsController < BaseController
    before_action :set_report, only: [:show, :destroy]
    layout 'admin_panel', except: [:show]

    def index
      @reports = Report.includes(:user, :reportable).page params[:page]
    end

    def destroy
      @report.destroy
    end

    private
    def set_report
      @report = Report.find(params[:id])
    end
  end
end
