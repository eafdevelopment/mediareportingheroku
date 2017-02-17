Rails.application.routes.draw do

  resources :home, only: :index
  resources :reports, only: :index
  resources :clients, only: [:index, :show] do
    resources :campaigns, only: [:new, :create, :edit, :destroy]
  end

  get 'home/update_campaigns', as: 'update_campaigns'
  get 'home/update_campaign_channels', as: 'update_campaign_channels'

  root to: 'home#index'
end
