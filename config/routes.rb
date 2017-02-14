Rails.application.routes.draw do

  resources :home, only: :index
  resources :reports, only: :index

  root to: 'home#index'
end
