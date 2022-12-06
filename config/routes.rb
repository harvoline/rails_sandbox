Rails.application.routes.draw do
  root "home#index"
  post '/parser', to: 'home#parser'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
