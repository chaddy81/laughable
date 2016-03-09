Rails.application.routes.draw do
  api_version(module: 'V1', path: { value: 'v1' }) do
    resources :search, only: [] do
      get 'info', on: :collection
      get 'search', on: :collection
    end

    resources :comedians, except: [:new, :destroy, :index, :edit, :create] do
      get 'info', on: :collection
      get 'all', on: :collection
      get 'tracks', on: :member
      get 'multiple', on: :collection
      get 'subscribe', on: :member
      get 'unsubscribe', on: :member
      get 'custom_update', on: :member
      get 'standuptracks', on: :member
      get 'guestpodcastepisodes', on: :member
      get 'hostedpodcasts', on: :member
      get 'list', on: :collection
      get 'alter_list', on: :member
    end

    resources :tracks, except: [:new, :edit, :destroy, :index, :update, :create] do
      get 'info', on: :collection
      get 'all', on: :collection
      get 'multiple', on: :collection
      get 'random', on: :collection
      get 'custom_update', on: :member
    end

    resources :users, except: [:new, :index, :edit, :destroy] do
      get 'info', on: :collection
      post 'login', on: :collection
    end

    resources :recommendations, only: [] do
      get 'info', on: :collection
      get 'short', on: :collection
      get 'long', on: :collection
      get 'next', on: :collection
      get 'recommended', on: :collection
      get 'alter', on: :collection
      get 'alter_up_next', on: :collection
      get 'alter_podcastepisode', on: :collection
      get 'up_next_list', on: :collection
      get 'banner', on: :collection
      get 'podcastepisode', on: :collection
      get 'popularepisodes', on: :collection
      get 'alter_popularepisodes', on: :collection
      get 'schedule_release', on: :collection
    end

    resources :podcasts, except: [:new, :create, :edit, :destroy, :index, :update] do
      get 'info', on: :collection
      get 'multiple', on: :collection
      get 'all', on: :collection
      get 'subscribe', on: :member
      get 'unsubscribe', on: :member
      get 'episodes', on: :member
      get 'guests', on: :member
      get 'custom_update', on: :member
      get 'featured_episodes', on: :member
      get 'alter_episodes', on: :member
      get 'alter_only_show_featured_episodes', on: :member
    end

    resources :podcastepisodes, except: [:new, :create, :edit, :destroy, :index, :update] do
      get 'info', on: :collection
      get 'multiple', on: :collection
      get 'all', on: :collection
      get 'custom_update', on: :member
      get 'set_progress', on: :member
    end

    resources :blacklist, only: [] do
      get 'info', on: :collection
      get 'blacklist', on: :member
      get 'unblacklist', on: :member
      get 'clear_all', on: :collection
      get 'list_all', on: :collection
    end

    resources :shortener, only: [] do
      get 'track', on: :collection
    end
  end

  # Sinatra mount for sidekiq, only in development
  #if Rails.env == 'development'
    require 'sidekiq/web'
    mount Sidekiq::Web => '/null'
  #end

  root 'info#index'
  resources :info, only: []

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'


  #post 'v1/cms' => 'v1/contents#create'
  #post 'v1/cms/upload' => 'v1/contents#upload'
  #post 'v1/cms/authenticate' => 'v1/contents#authenticate'
  match '/v1/cms' => 'v1/contents#create', via: [:post, :options]
  match '/v1/cms/upload' => 'v1/contents#upload', via: [:post, :options]
  match '/v1/cms/authenticate' => 'v1/contents#authenticate', via: [:post, :options]

  get '/:id' => "shortener/shortened_urls#show"
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
