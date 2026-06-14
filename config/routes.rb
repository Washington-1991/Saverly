Rails.application.routes.draw do
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
end
