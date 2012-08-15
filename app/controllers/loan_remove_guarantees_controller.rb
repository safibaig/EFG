class LoanRemoveGuaranteesController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]

  def new
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_remove_guarantee = LoanRemoveGuarantee.new(@loan)
  end

  def create
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_remove_guarantee = LoanRemoveGuarantee.new(@loan)
    @loan_remove_guarantee.attributes = params[:loan_remove_guarantee]
    @loan_remove_guarantee.modified_by = current_user

    if @loan_remove_guarantee.save
      redirect_to loan_url(@loan_remove_guarantee.loan), notice: 'The Guarantee has been removed in respect of this facility.'
    else
      render :new
    end
  end

  private

  def verify_create_permission
    enforce_create_permission(LoanRemoveGuarantee)
  end

end
