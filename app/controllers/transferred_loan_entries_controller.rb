class TransferredLoanEntriesController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]

  def new
    @loan = current_lender.loans.find(params[:loan_id])
    @transferred_loan_entry = TransferredLoanEntry.new(@loan)
  end

  def create
    @loan = current_lender.loans.find(params[:loan_id])
    @transferred_loan_entry = TransferredLoanEntry.new(@loan)
    @transferred_loan_entry.attributes = params[:transferred_loan_entry]
    @transferred_loan_entry.modified_by = current_user

    case params[:commit]
    when 'Save as Incomplete'
      @transferred_loan_entry.save_as_incomplete
      redirect_to loan_url(@transferred_loan_entry.loan)
    when 'State Aid Calculation'
      @transferred_loan_entry.save_as_incomplete
      redirect_to edit_loan_state_aid_calculation_url(@transferred_loan_entry.loan, redirect: 'transferred_loan_entry')
    else
      if @transferred_loan_entry.save
        redirect_to loan_url(@transferred_loan_entry.loan)
      else
        render :new
      end
    end
  end

  private
  def verify_create_permission
    enforce_create_permission(TransferredLoanEntry)
  end
end
