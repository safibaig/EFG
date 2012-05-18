EFG::Application.routes.draw do
  root to: 'dashboard#show'

  resources :loans, only: :show do
    collection do
      resource :eligibility_check, only: [:new, :create]
    end
  end
end
