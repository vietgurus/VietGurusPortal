Rails.application.routes.draw do
  scope '(:locale)', :locale => /en/ do
    root 'sessions#new'

    get 'login', to: 'sessions#new'
    post 'login', to: 'sessions#create'
    delete 'logout', to: 'sessions#destroy'
    post 'forgot_password_create', to: 'sessions#forgot_password_create'
    post 'new_password_create', to: 'sessions#new_password_create'
    get 'confirm_email', to: 'users#confirm_email'
    get 'users', to: 'users#index'
    post 'users/update_role/:id', to: 'users#update_role', as: :update_role
    post 'users/', to: 'users#create'

    resources :users do
      collection do
        get   'profile'
        get   'password'
        post  'update'
        post  'update_profile'
        post  'change_password'
      end
    end

    resources :posts do
      member do
        get 'up', to: 'posts#up'
        get 'down', to: 'posts#down'
      end
      collection do
        post 'update_result'
        get 'new_vote'
        get 'new_randomize'
        get 'votes', to: 'posts#index', defaults: { type: Post::TYPE_VOTE }
        get 'randomizes', to: 'posts#index', defaults: { type: Post::TYPE_RANDOM }
      end
    end

    resources :posts
  end


end
