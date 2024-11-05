Rails.application.routes.draw do
  post "/posts/new"   ,   to: "posts#new"
  post "/posts/create" ,  to: "posts#create"
  get "/posts/good_counter/:id"     , to: "posts#good_counter"
  delete "/posts/destroy/:id"       , to: "posts#destroy"
  get "/posts/edit/:id"             , to: "posts#edit"
  post "/posts/update/:id"        , to: "posts#update"

  get "/searches/top" ,   to: "searches#top"
  post "/searches/index" , to: "searches#index"
  get "/searches/show" ,  to: "searches#show"
  
  get "/login" ,     to: "sessions#new"
  post "/login" ,    to: "sessions#create"
  delete "/logout" , to: "sessions#destroy"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
  root "static_pages#home"
  resources :users
  resources :account_activations , only: [:edit]
  resources :password_resets,      only: [:new, :create, :edit, :update]
end