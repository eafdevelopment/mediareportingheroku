Rails.application.routes.draw do
  
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  resources :home, only: :index
  resources :reports, only: :index
  resources :clients do
    resources :client_channels, only: [:index]
    resources :campaigns, only: [:index, :new, :create, :edit, :destroy, :update] do
    end
  end
  resources :campaigns, only: [] do
    resources :campaign_channels, only: [:index]
  end
  resources :datasets, only: [:create, :destroy] do
    member do
      get :download
    end
  end

  root to: 'home#index'
end
