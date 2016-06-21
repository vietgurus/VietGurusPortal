Rails.application.routes.draw do
  get 'posts/index'

  scope '(:locale)', :locale => /en/ do
    root 'posts#index'
  end
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  post 'forgot_password_create', to: 'sessions#forgot_password_create'
  post 'new_password_create', to: 'sessions#new_password_create'
  get 'confirm_email', to: 'users#confirm_email'
  resources :users do
    collection do
      get   'profile'
      get   'password'
      post  'update'
      post  'update_profile'
      post  'change_password'
    end
  end

  post 'posts/update_result', to: 'posts#update_result'
  get 'posts/new_vote', to: 'posts#new_vote'
  get 'posts/new_randomize', to: 'posts#new_randomize'
  get 'posts', to: 'posts#my_posts'
  get 'posts/votes', to: 'posts#votes'
  get 'posts/randomizes', to: 'posts#randomizes'

end
