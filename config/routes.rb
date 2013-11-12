TwitterFlux::Application.routes.draw do
  resources :home do
    collection { get :stream }
  end
  root to: 'home#index'
end
