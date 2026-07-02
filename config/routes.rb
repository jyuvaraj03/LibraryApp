# frozen_string_literal: true

Rails.application.routes.draw do
  get 'sessions/new'
  resources :books, only: %i[create new index edit update]
  resources :members, only: %i[create new index]
  resources :book_rentals, only: %i[create new index]
  resources :returns, only: %i[create new]
  resources :member_book_rentals, only: %i[index]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'books#index'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
end
