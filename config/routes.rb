Rails.application.routes.draw do
  resources :games
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  post '/games/:id/turn', to: 'games#turn'
  get  '/games/:id', to: 'games#show'
  get  '/games', to: 'games#index'
  post '/games', to: 'games#create'
  delete '/games/:id', to: 'games#delete'
end
