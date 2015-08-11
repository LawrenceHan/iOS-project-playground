module AdminPanel
  class ReferralCodesController < BaseController
    before_action :set_referral_code, only: [:edit, :update, :destroy]
    layout 'admin_panel', except: [:edit]

    def index
      @referral_codes = ReferralCode.page params[:page]
    end

    def update
      @referral_code.update(referral_code_params)
    end

    def create
      @referral_codes = []
      if (count = params[:referral_code][:count].to_i) > 0
        @referral_codes = ReferralCode.generate_code_by_count(count)
      end
    end

    def destroy
      @referral_code.destroy
    end

    private
    def set_referral_code
      @referral_code = ReferralCode.find(params[:id])
    end

    def referral_code_params
      params.require(:referral_code).permit(:code, :memo)
    end
  end
end
