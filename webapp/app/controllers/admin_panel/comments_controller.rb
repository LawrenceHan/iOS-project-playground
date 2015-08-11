module AdminPanel
  class CommentsController < BaseController
    before_action :set_comment, only: [:destroy, :audit, :preview]
    layout 'admin_panel', except: [:preview]

    def index
      @comments = Comment.includes(:user, :writer).order(:status).page params[:page]
    end

    def destroy
      @comment.destroy
    end

    def audit
      @comment.update_column(:status, params[:as])
    end

    private
    def set_comment
      @comment = Comment.find(params[:id])
    end
  end
end
