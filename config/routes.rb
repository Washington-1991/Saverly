Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  # Rutas de autenticación
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  # Dashboard (protegido)
  root "dashboard#index"
  get "dashboard/index"

  # ════════════════════════════════════════════════
  # Rutas para la interfaz web de cuentas y movimientos
  # ════════════════════════════════════════════════
  resources :accounts, except: [ :show ] do
    # Opcional: si quieres listar movimientos de una cuenta, podrías añadir:
    # member { get :movements }
  end

  # Solo las rutas que necesitamos ahora
  resources :movements, only: [ :index, :new, :create ]

  # Panel de administración (solo admin)
  namespace :admin do
    resources :users, except: [ :show ]
  end

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
