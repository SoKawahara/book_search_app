Rails.application.routes.draw do
  #このルーティングファイルでは１番上にあるものから順番にマッチさせるので優先順位が高いものは上に書く

  #memberメソッドを用いることでパスの中にidを含むような名前付きルーティングを作成する
  #/users/id/following , /users/id/followersのようになる
  get "/users/:id/following" , to: "users#following"
  get "/users/:id/followers" , to: "users#followers"
  get "/users/profile/:id"   , to: "users#profile"
  get "/users/profile/:user_id/top/:id" , to: "users#setting_top"
  get "/users/profile_new/:id" , to: "users#profile_new"
  get "/users/profile/view_top/:id/:top_id" , to: "users#view_top"
  post "/users/setting_profile/:id" , to: "users#setting_profile"
  post "/users/profile_tmp_save"   , to: "users#profile_tmp_save"
  get "/users/profile_edit/:id"    , to: "users#profile_edit_new"
  post "/users/profile_edit/:id"   , to: "users#profile_edit"
  get "/users/profile/view_top_edit/:id/:top_id" , to: "users#view_top_edit"


  get "/posts/feed/:type"          , to: "posts#feed"
  post "/posts/new"   ,   to: "posts#new"
  post "/posts/create" ,  to: "posts#create"
  get "/posts/good_counter/:user_id/:id"     , to: "posts#good_counter"
  delete "/posts/destroy/:id"       , to: "posts#destroy"
  get "/posts/edit/:id"             , to: "posts#edit"
  get "/posts/:user_id/:post_id" ,  to: "posts#view_post"
  post "/posts/update/:id"        , to: "posts#update"
  get "/posts/:user_id/view_about/:id"     , to: "posts#view_about"

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
  resources :users               , except: [:show]
  resources :account_activations , only: [:edit]
  resources :password_resets,      only: [:new, :create, :edit, :update]
  resources :relationships,        only: [:create , :destroy]

  get "/users/:id/:type" , to: "users#show"
end