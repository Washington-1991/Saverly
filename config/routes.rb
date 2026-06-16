Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # Rutas de autenticación
  get "signup", to: "users#new"
  post "signup", to: "users#create"
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  # Dashboard (protegido)
  root "dashboard#index"
  get "dashboard/index"

  # Rutas existentes que no debes perder
  get "users/new"
  get "users/create"
  get "sessions/new"
  get "sessions/create"
  get "sessions/destroy"

  # Health check y PWA
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # API REST (backend JSON)
  namespace :api do
    namespace :v1 do
      resources :accounts, except: [ :new, :edit ]
      resources :movements, except: [ :new, :edit ]

      # Reportes y estadísticas
      resources :reports, only: [] do
        collection do
          get :balance
          get :income_vs_expense
          get :recent_movements
          get :monthly_summary
        end
      end
    end
  end
end
