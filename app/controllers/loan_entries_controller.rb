class LoanEntriesController < ApplicationController
  def new
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_entry = LoanEntry.new(@loan)
  end

  def create
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_entry = LoanEntry.new(@loan)
    @loan_entry.attributes = params[:loan_entry]

    if params[:commit] == 'Save as Incomplete'
      @loan_entry.save_as_incomplete
      redirect_to loan_url(@loan_entry.loan)
    elsif @loan_entry.save
      redirect_to loan_url(@loan_entry.loan)
    else
      render :new
    end
  end
end
