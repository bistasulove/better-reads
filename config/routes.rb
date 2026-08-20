Rails.application.routes.draw do
  # Defines the root path route ("/")
  root "sessions#new"
  
  resource :session
  resources :users
  resources :books do
    resource :vote, only: %i[create destroy], controller: "book_votes"
  end
  resources :reviews do
    resource :vote, only: %i[create destroy], controller: "review_votes"
  end
end
