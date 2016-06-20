Rails.application.routes.draw do
  root 'sessions#new'

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  post 'forgot_password_create', to: 'sessions#forgot_password_create'
  post 'new_password_create', to: 'sessions#new_password_create'
  get 'confirm_email', to: 'users#confirm_email'

  resources :users do
  end

end
