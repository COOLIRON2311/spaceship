Rails.application.routes.draw do
  post '/auth/sign_up', to: 'auth#sign_up'
  post 'auth/sign_in', to: 'auth#sign_up'

  post 'task/create', to: 'task#create'
  get 'task/result', to: 'task#result'
  get '/stats', to: 'stats#get'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
