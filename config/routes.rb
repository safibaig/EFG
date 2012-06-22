EFG::Application.routes.draw do
  devise_for :users

  root to: 'dashboard#show'

  resources :loans, only: [:show] do
    collection do
      resource :eligibility_check, only: [:new, :create]
    end

    resource :cancel, only: [:new, :create], controller: 'loan_cancels'
    resource :entry, only: [:new, :create], controller: 'loan_entries'
    resource :offer, only: [:new, :create], controller: 'loan_offers'
    resource :guarantee, only: [:new, :create], controller: 'loan_guarantees'
    resource :entry, only: [:new, :create], controller: 'loan_entries'
    resource :demand_to_borrower, only: [:new, :create], controller: 'loan_demand_to_borrowers'
    resource :repay, only: [:new, :create], controller: 'loan_repays'
    resource :no_claim, only: [:new, :create], controller: 'loan_no_claims'
    resource :demand_against_government, only: [:new, :create], controller: 'loan_demand_against_government'
    resource :state_aid_calculation, only: [:new, :create, :edit, :update]
  end

  resources :documents, only: [] do
    member do
      get :state_aid_letter
      get :information_declaration
    end
  end

  resources :loan_states, only: [:index, :show]

  resources :loan_alerts, only: [] do
    collection do
      get :not_drawn
      get :demanded
      get :not_progressed
      get :assumed_repaid
    end
  end

  resources :users, only: [:index, :show, :new, :create, :edit, :update]
end
