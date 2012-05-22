class LoanEntriesController < ApplicationController
  def new
    @loan = Loan.find(params[:loan_id])
    @loan_entry = LoanEntry.new(@loan)
  end
end
