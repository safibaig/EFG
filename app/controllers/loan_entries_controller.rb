class LoanEntriesController < ApplicationController
  def new
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_entry = LoanEntry.new(@loan)
  end
end
