Rails.application.routes.draw do
  resource :user do
    post '/user/sign_up', to: 'users#sign_up'
    post '/user/sign_in', to: 'users#sign_in'
  end

  resource :task do
    post '/task/create', to: 'tasks#create'
    get '/task/result', to: 'tasks#result'
  end

  resource :stat do
    get '/stats', to: 'stats#get'
  end


  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
