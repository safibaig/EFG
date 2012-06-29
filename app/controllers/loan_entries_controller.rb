class LoanEntriesController < ApplicationController
  def new
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_entry = LoanEntry.new(@loan)
  end

  def create
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_entry = LoanEntry.new(@loan)
    @loan_entry.attributes = params[:loan_entry]

    case params[:commit]
    when 'Save as Incomplete'
      @loan_entry.save_as_incomplete
      redirect_to loan_url(@loan_entry.loan)
    when 'State Aid Calculation'
      @loan_entry.save_as_incomplete
      redirect_to edit_loan_state_aid_calculation_url(@loan_entry.loan, redirect: 'loan_entry')
    else
      if @loan_entry.save
        redirect_to loan_url(@loan_entry.loan)
      else
        render :new
      end
    end
  end
end
