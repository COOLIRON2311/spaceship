Rails.application.routes.draw do
  root 'home#index'

  post 'auth/sign_up', to: 'auth#sign_up'
  post 'auth/log_in', to: 'auth#log_in'
  get 'auth/welcome'

  get 'auth/log_in'
  get 'auth/sign_up'

  post 'task/post', to: 'tasks#post'
  get 'task/result', to: 'tasks#result'

  get '/stats', to: 'stats#get'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
