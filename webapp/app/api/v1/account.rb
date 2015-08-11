module V1
  module Account
    class API < Grape::API
      namespace :account do
        mount Registration::API
        mount Session::API
        mount Confirmation::API
        mount Password::API
        mount Profiles::API
        mount Authentications::API
        mount Users::API
      end
    end
  end
end
