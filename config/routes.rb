Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  post '/sign-up', to: 'auth#sign_up'
  post '/log-in', to: 'auth#log_in'
  get '/me', to: 'auth#me'

  post '/groups', to: 'group#create'
  get '/groups', to: 'group#get_all'

  post '/transactions', to: 'transaction#create'
  get '/transactions', to: 'transaction#get_all'
end
