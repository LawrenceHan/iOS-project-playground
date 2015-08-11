# FIXME: rename to V2::Admin after merging User and Admin
module V2::Administrator
  class API < Grape::API
    namespace :admin do
      mount Session::API
      mount Users::API
    end
  end
end
