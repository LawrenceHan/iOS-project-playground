# Notice: We can't use Feedback as module name.
module V1::FeedbackApi
  class API < Grape::API

    helpers AuthorizeHelper

    before do
      authenticate!
    end

    resource :feedback do
      desc 'Post a feedback [require login]'
      params do
        requires :feedback, type: Hash do
          requires :content, type: String, desc: 'feedback content'
          optional :app_version, type: String, desc: 'system version'
          optional :device_model, type: String, desc: 'device model'
          optional :system_version, type: String, desc: 'system version'
        end
      end
      post do
        feedback = current_user.feedback.new(get_params_data(:feedback, [:content, :app_version, :device_model, :system_version]))
        if feedback.save
          say_succeed
        else
          say_failed feedback
        end
      end
    end
  end
end
