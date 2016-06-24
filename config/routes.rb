Rails.application.routes.draw do
  scope '(:locale)', :locale => /en/ do
    root 'sessions#new'

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
    get 'posts/votes', to: 'posts#index', defaults: { type: Post::TYPE_VOTE }
    get 'posts/randomizes', to: 'posts#index', defaults: { type: Post::TYPE_RANDOM }

    resources :posts do
      member do
        get 'up', to: 'posts#up'
        get 'down', to: 'posts#down'
      end
    end

    resources :posts
  end


end
