class EligibilityChecksController < ApplicationController
  def new
    @loan_eligibility_check = LoanEligibilityCheck.new
  end

  def create
    @loan_eligibility_check = LoanEligibilityCheck.new(params[:loan_eligibility_check])

    if @loan_eligibility_check.save
      redirect_to @loan_eligibility_check.loan
    else
      render :new
    end
  end
end
