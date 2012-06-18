class DashboardController < ApplicationController
  def show
    @utilisation_presenter = UtilisationPresenter.new(current_user.lender)
  end
end
