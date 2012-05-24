EFG::Application.routes.draw do
  devise_for :users

  root to: 'dashboard#show'

  resources :loans, only: :show do
    collection do
      resource :eligibility_check, only: [:new, :create]
    end

    resource :entry, only: [:new, :create], controller: 'loan_entries'
  end

  resources :users, only: [:index, :show, :new, :create, :edit, :update]
end
