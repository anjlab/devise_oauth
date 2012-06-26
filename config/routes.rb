Devise::Oauth::Engine.routes.draw do
  resource :authorization, path: :authorize, only: [:create, :show, :destroy], defaults: {format: :html}
  resource :access_token,  path: :token,     only: [:create, :destroy], defaults: {format: :json}

  resources :clients do
    put :block,   on: :member
    put :unblock, on: :member
  end

  resources :access, only: [:index, :show] do
    put :block,   on: :member
    put :unblock, on: :member
  end
end