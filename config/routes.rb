Znaigorod::Application.routes.draw do
  namespace :manage do
    match 'geocoder' => 'geocoder#get_coordinates'

    resources :affiches, :except => :show
    resources :organizations, :except => :show

    root :to => 'organizations#index'
  end

  resources :affiches, :only => [:index, :show]
  resources :organizations, :only => [:index, :show]

  root :to => 'application#main_page'
end
