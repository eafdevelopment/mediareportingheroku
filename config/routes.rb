Rails.application.routes.draw do

  resources :home, only: :index
  resources :reports, only: :index
  resources :clients, only: [:index, :show]
  resources :campaigns, only: [:new, :create]

  get 'home/update_campaigns', as: 'update_campaigns'

  root to: 'home#index'
end
