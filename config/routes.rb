Wattle::Application.routes.draw do
  # You can have the root of your site routed with "root"
  root to: 'groupings#index'

  resources :wats

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
