class LoanEligibilityDecisionsController < ApplicationController

  before_filter :find_loan

  def show
    @eligibility_decision_email = EligibilityDecisionEmail.new
    render @loan.state
  end

  def email
    @eligibility_decision_email = EligibilityDecisionEmail.new(params[:eligibility_decision_email])
    if @eligibility_decision_email.valid?
      # send email
    else
      render :show
    end
  end

  private

  def find_loan
    @loan = current_lender.loans.where(state: [ Loan::Eligible, Loan::Rejected ]).find(params[:loan_id])
  end

end
