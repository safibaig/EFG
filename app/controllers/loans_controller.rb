class LoansController < ApplicationController
  def show
    @loan = current_lender.loans.find(params[:id])
  end
end
