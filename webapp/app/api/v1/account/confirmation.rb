module V1::Account
  module Confirmation
    class API < Grape::API

      helpers AuthorizeHelper

      resource :confirmation do

        desc 'Resend confirmation email [require login]'
        post do
          authenticate!
          current_user.send_confirmation_instructions
          say_succeed
        end
      end

    end
  end
end
