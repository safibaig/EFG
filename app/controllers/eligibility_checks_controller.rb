class EligibilityChecksController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]

  def new
    @loan = current_lender.loans.new
    @loan_eligibility_check = LoanEligibilityCheck.new(@loan)
  end

  def create
    @loan = current_lender.loans.new
    @loan_eligibility_check = LoanEligibilityCheck.new(@loan)
    @loan_eligibility_check.attributes = params[:loan_eligibility_check]
    @loan_eligibility_check.created_by = current_user
    @loan_eligibility_check.modified_by = current_user

    # all new loans belong to EFG scheme
    @loan_eligibility_check.loan_scheme = Loan::EFG_SCHEME
    @loan_eligibility_check.loan_source = Loan::SFLG_SOURCE

    if @loan_eligibility_check.save
      redirect_to loan_eligibility_decision_url(@loan_eligibility_check.loan)
    else
      render :new
    end
  end

  private
  def verify_create_permission
    enforce_create_permission(LoanEligibilityCheck)
  end
end
