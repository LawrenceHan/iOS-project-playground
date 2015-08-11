require 'rails_helper'

describe V1::FeedbackApi::API do
  describe "POST /v1/feedback" do
     before do
       user = create :user
       login_as user
       allow_any_instance_of(Feedback).to receive(:notify_the_administrators).and_return(true)
     end

     it "creates a feedback" do
       expect {
         post "/v1/feedback", feedback: {content: "content"}
       }.to change { Feedback.count }.by(1)
       expect(response.status).to eq 201
     end

     it "failed to create a feedback" do
       expect {
         post "/v1/feedback", feedback: {}
       }.not_to change { Feedback.count }
       expect(response.status).to eq 500
     end
  end
end
