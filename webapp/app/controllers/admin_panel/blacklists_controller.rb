module AdminPanel
  class BlacklistsController < BaseController
    before_action :set_blacklist, only: [:edit, :update, :destroy]
    layout 'admin_panel', except: [:new, :edit]

    def index
      @blacklists = Blacklist.page params[:page]
    end

    def new
      @blacklist = Blacklist.new
    end

    def create
      @blacklist = Blacklist.new(blacklist_params)
      @blacklist.save
    end

    def update
      @blacklist.update(blacklist_params)
    end

    def destroy
      @blacklist.destroy
    end

    private
    def set_blacklist
      @blacklist = Blacklist.find(params[:id])
    end

    def blacklist_params
      params.require(:blacklist).permit(:word)
    end
  end
end
