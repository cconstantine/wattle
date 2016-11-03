require 'sidekiq/web'
require 'sidekiq/cron/web'

class LoginConstraint
  class << self
    def matches?(request)
      Watcher.where(id: request.session[:watcher_id]).any?
    end
  end
end


Wattle::Application.routes.draw do
  # You can have the root of your site routed with "root"
  root to: 'groupings#index'

  constraints LoginConstraint do
    mount Sidekiq::Web => '/sidekiq'
  end
  mount WatCatcher::Engine => '/wat_catcher'
  mount SidekiqHealthcheck::Engine, at: '/sidekiq_healthcheck'


  resources :wats
  resources :watchers do
    member do
      post :reactivate
      post :deactivate
      post :reset_api_key
      post :refresh_projects
    end
  end

  get '/create/wat' => 'wats#create'
  resources :stats, only: :index
  
  get '/aggregate_wats/:scale', to: "aggregate_wats#periodic"
  get "/groupings/:state", to: "groupings#index", as: :groupings_state, constraints: { :state => /[a-zA-Z]+/ }

  resources :groupings

  resource :search, only: :show

  resources :notes, only: :destroy
  resources :trackers, only: :create

  resources :groupings do
    resources :notes, only: :create
    resources :wats, only: [:show, :index]

    member do
      post :resolve
      post :deprioritize
      post :acknowledge
    end
  end

  resource :exceptionals, only: [:show] do
    get :an_exception
    get :rendered_exception
  end
  namespace :api do 
    resources :groupings do
      get :count_by_state, on: :collection
      get '/count/:state', on: :collection, to: "groupings#count"
    end
  end

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match '/auth', to: 'sessions#delete', via: [:delete]

end
