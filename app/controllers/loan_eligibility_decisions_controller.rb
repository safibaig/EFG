class LoanEligibilityDecisionsController < ApplicationController

  def show
    @loan = current_lender.loans.where(state: [ Loan::Eligible, Loan::Rejected ]).find(params[:loan_id])
  end

end
