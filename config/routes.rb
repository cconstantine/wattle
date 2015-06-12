require 'sidekiq/web'

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

  resources :wats
  resources :watchers do
    member do
      post :reactivate
      post :deactivate
      post :reset_api_key
    end
  end

  get '/create/wat' => 'wats#create'

  get '/aggregate_wats/:scale', to: "aggregate_wats#periodic"

  resources :grouping_unsubscribes, only: :destroy
  resources :groupings do
    resources :grouping_unsubscribes, only: :create
  end

  resources :grouping_owners, only: :destroy
  resources :groupings do
    resources :grouping_owners, only: :create
  end

  resources :groupings do
    resources :notes, only: :create
    resources :wats, only: [:show, :index]

    member do
      get  :chart
      post :resolve
      post :deprioritize
      post :acknowledge
    end
  end

  resource :exceptionals, only: [:show] do
    get :an_exception
    get :rendered_exception
  end

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match '/auth', to: 'sessions#delete', via: [:delete]

end
