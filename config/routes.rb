Rails.application.routes.draw do
  root 'home#index'

  post 'auth/sign_up', to: 'auth#sign_up'
  post 'auth/log_in', to: 'auth#log_in'
  get 'auth/welcome'

  get 'home/log_in_page'
  get 'home/sign_up_page'


  post 'task/create', to: 'tasks#create'
  get 'task/result', to: 'tasks#result'

  get '/stats', to: 'stats#get'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
