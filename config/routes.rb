Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  post '/sign-up', to: 'auth#sign_up'
  post '/log-in', to: 'auth#log_in'
end
