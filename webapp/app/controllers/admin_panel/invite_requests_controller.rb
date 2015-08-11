module AdminPanel
  class InviteRequestsController < BaseController
    before_action :set_invite_request, only: :destroy

    def index
      @invite_requests = InviteRequest.all.page params[:page]
    end

    def destroy
      @invite_request.destroy
    end

    private
    def set_invite_request
      @invite_request = InviteRequest.find(params[:id])
    end
  end
end
