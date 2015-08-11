module V1::Reviews
  module Answers
    class API < Grape::API

      helpers AuthorizeHelper

      before do
        authenticate!
      end

      resource :answers do
        desc 'Rate review [require login]'
        params do
          requires :answer, type: Hash do
            requires :review_id, type: Integer, desc: 'review id'
            requires :question_id, type: Integer, desc: 'question id'
            optional :waiting_time, type: Integer, desc: 'waiting time'
            optional :rating, type: Integer, desc: 'rating'
          end
        end
        post do
          answer = Answer.new(get_params_data(:answer, [:review_id, :question_id, :waiting_time, :rating]))
          if answer.save
            say_succeed answer
          else
            say_failed answer
          end
        end
      end
    end
  end
end
