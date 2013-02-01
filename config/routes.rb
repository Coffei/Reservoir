Reservoir::Application.routes.draw do
  
  get '/rooms/remote/calendar/update', :to => "rooms#start_remotecal_worker", :as => "remote_calendar_update"
  resources :rooms do
    get "/reservations/remote", :to => "reservations#index_remote"
    post "/reservations/deletemany", :to => "reservations#destroymany"
    get "/remote/calendar/update", :to => "rooms#start_remotecal_worker", :as => "remote_calendar_update"
    resources :reservations 
  end
 
  devise_for :users, controllers: { registrations: "registrations" }
  devise_scope :user  do
    get '/login', :to => 'devise/sessions#new', :as => "login"
    get '/register', :to => 'devise/registrations#new', :as => "register"
    get '/users/edit/password', :to => 'registrations#edit_password', :as => "user_password_change"
    get '/users/show/:id', :to => "registrations#show", :as => "user"   
  end

  get '/users/show/:id/reservations', :to => "reservations#indexByUser", :as => "user_reservations"
  get '/reservations/find', :to => "reservations#find"
  post '/reservations/find', :to => "reservations#search"
  post '/search', :to => "home#search", :as => "search"
  
  
  
  root :to => "home#index"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
