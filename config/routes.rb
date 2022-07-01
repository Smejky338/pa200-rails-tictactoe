Rails.application.routes.draw do
  resources :games
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  post '/games/:id/turn', to: 'games#turn'
end
