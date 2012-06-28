class LoansController < ApplicationController
  before_filter :load_loan, only: [:show, :details]

  def show
  end

  def details
  end

  private
  def load_loan
    @loan = current_lender.loans.find(params[:id])
  end
end
