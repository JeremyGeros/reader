require 'sidekiq/web'
require 'admin_constraint'

Rails.application.routes.draw do
  get '/all', to: 'feeds#all', as: 'feed_all'
  get '/feeds', to: 'feeds#feeds', as: 'feed_feeds'
  get '/read_later', to: 'feeds#read_later', as: 'feed_read_later'
  get '/read', to: 'feeds#read', as: 'feed_read'

  get '/keyboard_shortcuts', to: 'feeds#keyboard_shortcuts', as: 'keyboard_shortcuts'
  
  resources :articles do
    member do
      get 'reparse'
    end
  end

  resources :sources do
    member do
      get 'scan'
      get 'preview'
    end
  end

  resources :notes do
  end

  resources :users, only: [:edit, :update, :destroy]
  get 'settings', to: 'users#edit', as: 'settings'

  resources :imports, only: [:index, :show, :create] do
    get 'status', on: :member
  end


  get 'external/read_later', to: 'external_articles#read_later', as: 'external_read_later'

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
  root "feeds#all"
end
