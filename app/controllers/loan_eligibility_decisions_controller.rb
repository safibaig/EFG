class LoanEligibilityDecisionsController < ApplicationController

  before_filter :find_loan

  def show
    if @loan.state == Loan::Eligible
      @eligibility_decision_email = EligibilityDecisionEmail.new
      render "eligible"
    else
      render "ineligible"
    end
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
    @loan = current_lender.loans.where(state: Loan::Eligible).find(params[:loan_id])
  end

end
