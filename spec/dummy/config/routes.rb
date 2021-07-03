Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :projects, only: %i[index show new create edit update destroy]
  resources :tasks, only: [:new, :create]

  root to: "projects#new"
end
