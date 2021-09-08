Rails.application.routes.draw do

  devise_for :users
  root "dashboard#index"
  get 'project/new'
  get 'projects' => 'project#index'

  post 'project/create'
end
