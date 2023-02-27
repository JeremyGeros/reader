require 'sidekiq/web'
require 'admin_constraint'

Rails.application.routes.draw do
  resources :feeds, only: [:index]
  
  resources :articles, only: [:index, :show]
  
  resources :sources do
    member do
      get 'scan'
    end
  end

  resources :notes do
  end


  # Admin
  mount Sidekiq::Web => '/admin/sidekiq', :constraints => AdminConstraint.new
  mount PgHero::Engine, at: "/admin/pghero", :constraints => AdminConstraint.new

  # Authentication
  get 'signup', to: 'signup#new', as: 'signup'
  post 'signup', to: 'signup#create'

  resources :sessions, only: [:create]
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'

  # ROOT
  root "feeds#index"
end
