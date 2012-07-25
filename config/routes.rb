EFG::Application.routes.draw do
  devise_for :users

  root to: 'dashboard#show'

  resources :loans, only: [:show] do
    collection do
      resource :eligibility_check, only: [:new, :create]
    end

    member do
      get :details
    end

    resource :cancel, only: [:new, :create], controller: 'loan_cancels'
    resource :entry, only: [:new, :create], controller: 'loan_entries'
    resource :offer, only: [:new, :create], controller: 'loan_offers'
    resource :guarantee, only: [:new, :create], controller: 'loan_guarantees'
    resource :entry, only: [:new, :create], controller: 'loan_entries'
    resource :transferred_entry, only: [:new, :create], controller: 'transferred_loan_entries'
    resource :demand_to_borrower, only: [:new, :create], controller: 'loan_demand_to_borrowers'
    resource :repay, only: [:new, :create], controller: 'loan_repays'
    resource :no_claim, only: [:new, :create], controller: 'loan_no_claims'
    resource :demand_against_government, only: [:new, :create], controller: 'loan_demand_against_government'
    resource :state_aid_calculation, only: [:edit, :update]
    resource :premium_schedule, only: [:show], controller: 'premium_schedule'
    resource :remove_guarantee, only: [:new, :create], controller: 'loan_remove_guarantees'

    resources :loan_changes, only: [:index, :show, :new, :create]
    resources :recoveries, only: [:new, :create]
  end

  resources :documents, only: [] do
    member do
      get :state_aid_letter
      get :information_declaration
    end

    collection do
      get :data_protection_declaration
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

  resource :search, only: [:show, :new], controller: :search do
    collection do
      get :lookup
    end
  end

  resources :invoices, only: [:show, :new, :create] do
    collection do
      post :select_loans
    end
  end

  resources :realise_loans, only: [:show, :new, :create] do
    collection do
      post :select_loans
    end
  end

  resources :loan_transfers, only: [:show, :new, :create]
  resources :legacy_loan_transfers, only: [:show, :new, :create]

end
