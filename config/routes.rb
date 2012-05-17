EFG::Application.routes.draw do
  root to: 'dashboard#show'

  namespace :loans do
    resource :eligibility_check, only: [:new, :create]
  end
end
