Rails.application.routes.draw do

  resources :home, only: :index
  resources :reports, only: :index

  get 'home/update_campaigns', as: 'update_campaigns'

  root to: 'home#index'
end
