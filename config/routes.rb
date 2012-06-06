EFG::Application.routes.draw do
  devise_for :users

  root to: 'dashboard#show'

  resources :loans, only: [:show] do
    collection do
      resource :eligibility_check, only: [:new, :create]
    end

    resource :entry, only: [:new, :create], controller: 'loan_entries'
    resource :offer, only: [:new, :create], controller: 'loan_offers'
    resource :guarantee, only: [:new, :create], controller: 'loan_guarantees'
    resource :entry, only: [:new, :create], controller: 'loan_entries'
    resource :state_aid_calculation, only: [:new, :create, :edit, :update]
  end

  resources :loan_states, only: [:index, :show]

  resources :users, only: [:index, :show, :new, :create, :edit, :update]
end
