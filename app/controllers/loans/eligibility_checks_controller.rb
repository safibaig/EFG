class Loans::EligibilityChecksController < ApplicationController
  def new
    @loan_eligibility_check = LoanEligibilityCheck.new
  end
end
