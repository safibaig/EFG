class LoanModificationsController < ApplicationController
  before_filter :verify_view_permission
  before_filter :load_loan

  def index
    @loan_modifications = @loan.loan_modifications
  end

  def show
    @loan_modification = @loan.loan_modifications.find(params[:id])
  end

  private
    def load_loan
      @loan = current_lender.loans.find(params[:loan_id])
    end

    def verify_view_permission
      enforce_view_permission(LoanModification)
    end
end
