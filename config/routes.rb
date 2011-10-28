TasteOCodeWeb::Application.routes.draw do

  devise_for :users

  root :to => "home#show"

  resources :users, :only => [:index, :show, :edit, :update]

  resources :languages, :only => [:index, :show]

  match '/home', :to => 'home#show', :as => :home

  match '/about', :to => 'about#show', :as => :about

end
