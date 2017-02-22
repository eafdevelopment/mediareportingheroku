Rails.application.routes.draw do

  resources :home, only: :index
  resources :reports, only: :index
  resources :clients, only: [:index, :show] do
    resources :campaigns, only: [:index, :new, :create, :edit, :destroy, :update] do
    end
  end
  resources :campaigns, only: [] do
    resources :campaign_channels, only: [:index]
  end
  
  # get 'home/update_campaigns', as: 'update_campaigns'
  # get 'home/update_campaign_channels', as: 'update_campaign_channels'

  root to: 'home#index'
end
