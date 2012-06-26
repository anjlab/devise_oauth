Rails.application.routes.draw do
  devise_for :users

  mount Devise::Oauth::Engine => "/oauth"

  resources :protected_resources
end