Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :cats
  resources :cat_rental_requests do
    member do
      get 'approve', as: 'approve'
      get 'deny', as: 'deny'
    end
  end
end
