require 'api/api'

Rails.application.routes.draw do

  devise_for :users
  API::API.logger Rails.logger
  
  mount API::API => '/'

  resource :parse_objects
  resources :users
  resources :photos
end
