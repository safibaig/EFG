class LoanStatesController < ApplicationController
  def show
    @loans = current_lender.loans.with_state(params[:id])
  end
end
