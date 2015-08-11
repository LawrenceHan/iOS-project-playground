require "resque_web"

Carevoice::Application.routes.draw do
  namespace :api do
    get 'recover/index', to: API::RecoverController.action(:index), as: :edit_password
    put 'recover/update', to: API::RecoverController.action(:update), as: :update_password
    get 'pages/terms', to: API::PagesController.action(:terms), as: :terms
    get 'pages/invite/:email', to: API::PagesController.action(:invite), as: :invite, constraints: { email: /[^\/]+(?=\.html\z|\.json\z)|[^\/]+/ }
    get 'pages/invitation', to: API::PagesController.action(:invitation), as: :invitation
    get 'pages/invited_app_address', to: API::PagesController.action(:invited_app_address), as: :invited_app_address
    get "confirmation/confirm", to: API::ConfirmationController.action(:confirm), as: :confirm
  end

  # Can't use :admin as namespace name
  namespace :admin_panel do
    resque_web_constraint = lambda do |request|
      request.session[:admin_id].present?
    end
    constraints resque_web_constraint do
      ResqueWeb::Engine.eager_load!
      mount ResqueWeb::Engine => "/resque"
    end

    resources :users, only: [:index, :destroy, :new, :create] do
      get :profile, on: :member
      get :export, on: :collection
      post :login_as, on: :member
    end
    resources :admins, except: :show
    resources :conditions, except: :show
    resources :blacklists, except: :show
    resources :symptoms, except: :show
    resources :authentications, only: [:index, :show]
    resources :comments, only: [:index, :destroy] do
      member do
        get :preview
        put :audit
      end
    end
    resources :hospitals, except: :show do
      get :physicians, on: :member
      get :departments, on: :member
      get :map, on: :member
      put :update_geocoding, on: :member
    end
    resources :medications, except: :show
    resources :companies, except: :show
    resources :physicians, except: :show
    resources :departments, except: :show
    resources :specialities, except: :show
    resources :medical_experiences, except: [:new, :create] do
      get :export, on: :collection
    end
    resources :reviews, only: [:index, :show, :destroy, :edit, :update] do
      get :export, on: :collection
      member do
        get :preview
        put :audit
      end
    end
    resources :referral_codes, except: [:show, :new]
    resources :questions, except: :show
    resources :reports, only: [:index, :destroy, :show]
    resources :feedback, only: [:index, :destroy]
    resources :invitations, only: [:index, :destroy]
    resources :invite_requests, only: [:index, :destroy]
    resources :qrcodes, only: [:index, :new, :create, :edit, :update]
    resources :coupon_codes, only: [:index, :create, :update]
    resources :surveys

    get 'push_notification', controller: :push_notifications, action: :index
    post 'push_notification', controller: :push_notifications, action: :create
    post 'push_notification/payload_size', controller: :push_notifications, action: :payload_size

    get 'sms_message', controller: :sms_messages, action: :index
    post 'sms_message', controller: :sms_messages, action: :create

    get 'app_message', controller: :app_messages, action: :index
    post 'app_message', controller: :app_messages, action: :create

    resources :mailboxer_messages

    match "logout" => 'session#destroy', via: [:get, :delete]
    post 'login' => 'session#create'
    get  'login' => 'session#new'

    root 'admins#index', as: :admin_root
  end

  scope module: 'survey' do
    resources :surveys, only: [:show] do
      member do
        get :success
      end
      resources :feedbacks, only: [:create]
    end
  end

  namespace :mobile do
    get 'tutorial/intro' => 'tutorial#intro'
    get 'tutorial/welcome' => 'tutorial#welcome'

    get 'password/recover' => 'password#recover'

    get :sign_in, to: 'sessions#new'
    post :sign_in, to: 'sessions#create'
    match :sign_out, to: 'sessions#destroy', via: [:get, :delete]

    get :sign_up, to: 'registrations#new'
    post :sign_up, to: 'registrations#create'
    post :request_validation, to: 'registrations#request_validation_code'

    get 'registrations/step_one' => 'registrations#step_one'
    get 'registrations/step_two' => 'registrations#step_two'
    get 'registrations/step_three' => 'registrations#step_three'

    patch 'registrations/step_one' => 'profiles#update'
    patch 'registrations/step_two' => 'profiles#update'
    patch 'registrations/step_three' => 'profiles#update'

    resource :my_account, only: [:show, :edit, :update] do
      resources :health_conditions, only: [:index]
      resources :medical_experiences, only: [:index]

      get :settings
      get :avatar
      get :personal_infos
      get 'get_cities_for(/:region_name)', to: :get_cities_for, as: :get_cities_for
      get :social
    end

    resources :medical_experiences do
      resources :health_conditions, only: [:index]
    end

    resources :profiles
    resources :physicians, only: [:index, :show] do
      resources :reviews, only: [:index, :new, :create]
    end
    resources :hospitals, only: [:index, :show] do
      resources :physicians, only: [:index]
      resources :departments, only: [:index] do
        resources :physicians, only: [:index]
      end

      resources :reviews, only: [:index, :new, :create]
      collection do
        get :in_area
        get :search
      end
    end
    resources :medications, only: [:index, :show] do
      resources :reviews, only: [:index, :new, :create]
    end
    resources :reviews, only: [:show, :destroy]
    resources :specialities, only: :index do
      resources :physicians, only: :index
    end

    resources :feedback, only: [:new, :create]

    resources :users, only: [:show] do
      resources :reviews, only: [:index]
    end

    get 'search', to: 'search#index'
    get 'search/physician', to: 'search#physician'
    get 'search/review_search_menu', to: 'search#review_search_menu'
    get 'search/review_add_conditions', to: 'search#review_add_conditions'
    get 'search/review', to: 'search#review'
    get 'search/review/health_conditions', to: 'health_conditions#index'

    get 'about', to: 'pages#about'
    get 'terms', to: 'pages#terms'

    get 'guest_flow', to: 'guest_flow#index'
    get 'guest_flow/medical_experience', to: 'guest_flow#start_medical_experience'

    root 'tutorial#intro'
  end

  mount V2::CV::API => '/v2'
  mount V1::CV::API => '/v1'

  resources :qrcodes, only: [:show]

  root to: redirect {'/mobile'}

  get '/admin', to: redirect { '/admin_panel' }
end
