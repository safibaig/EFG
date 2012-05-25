class EligibilityChecksController < ApplicationController
  def new
    @loan = current_lender.loans.new
    @loan_eligibility_check = LoanEligibilityCheck.new(@loan)
  end

  def create
    @loan = current_lender.loans.new
    @loan_eligibility_check = LoanEligibilityCheck.new(@loan)
    @loan_eligibility_check.attributes = params[:loan_eligibility_check]

    if @loan_eligibility_check.save
      redirect_to @loan_eligibility_check.loan
    else
      render :new
    end
  end
end
