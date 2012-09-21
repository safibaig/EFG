class LoanEligibilityDecisionsController < ApplicationController

  before_filter :verify_create_permission
  before_filter :find_loan

  def show
    @eligibility_decision_email = EligibilityDecisionEmail.new(@loan)
    render @loan.state
  end

  def email
    @eligibility_decision_email = EligibilityDecisionEmail.new(@loan, params[:eligibility_decision_email])
    if @eligibility_decision_email.valid?
      @eligibility_decision_email.deliver_email
      redirect_to loan_path(@loan), notice: "Your email was sent successfully"
    else
      render @loan.state
    end
  end

  private

  def find_loan
    @loan = current_lender.loans.where(state: [ Loan::Eligible, Loan::Rejected ]).find(params[:loan_id])
  end

  def verify_create_permission
    enforce_create_permission(LoanEligibilityCheck)
  end

end
