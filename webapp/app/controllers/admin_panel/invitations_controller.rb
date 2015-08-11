module AdminPanel
  class InvitationsController < BaseController
    before_action :set_invitation, only: :destroy

    def index
      @invitations = Invitation.all.page(params[:page])
    end

    def destroy
      @invitation.destroy
    end

    private
    def set_invitation
      @invitation = Invitation.find(params[:id])
    end
  end
end
