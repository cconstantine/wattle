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

  resources :wats
  get '/create/wat' => 'wats#create'

  resources :groupings do
    resources :wats, only: [:show, :index]
    member do
      post :resolve
      post :acknowledge
      post :activate
    end
  end

  resource :exceptionals, only: [:show] do
    get :an_exception
    get :rendered_exception
  end

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]

end
