require 'rails_helper'

describe ApplicationController do
  controller do
    def index
      render :text => "hello"
    end
  end

  it "should set the logged in current_user to User.current_user_id in an around filter" do
    allow(controller).to receive(:set_current_user_id) { nil }
    get :index
  end

  it "set_current_user_id should fetch the current_user and set its id" do
    @user = double('user', :id => 1)
    allow(controller).to receive(:current_user) { @user }
    allow(User).to receive(:current_user_id=).twice
    get :index
  end
end