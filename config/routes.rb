Rails.application.routes.draw do
  get 'posts/index'

  scope '(:locale)', :locale => /en/ do
    root 'posts#index'

    get    'login',  to: 'sessions#new'
    post   'login',  to: 'sessions#create'
    delete 'logout', to: 'sessions#destroy'
    post   'forgot_password_create',  to: 'sessions#forgot_password_create'
    post   'new_password_create',     to: 'sessions#new_password_create'
    get    'confirm_email', to: 'users#confirm_email'

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
    end

  end
end
