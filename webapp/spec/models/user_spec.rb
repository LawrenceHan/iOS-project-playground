require 'rails_helper'

describe User do
  it "should have current_user_id class accessors to get and set current user id" do
    User.current_user_id = nil
    expect(User.current_user_id).to eq(nil)
    User.current_user_id = 1
    expect(User.current_user_id).to eq(1)
    User.current_user_id = nil
  end
end