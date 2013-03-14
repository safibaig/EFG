class LoanEntriesController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]
  before_filter :load_loan
  rescue_from_incorrect_loan_state_error

  def new
    @loan_entry = LoanEntry.new(@loan)
  end

  def create
    @loan_entry = LoanEntry.new(@loan)
    @loan_entry.attributes = params[:loan_entry]
    @loan_entry.modified_by = current_user

    case params[:commit]
    when 'Save as Incomplete'
      @loan_entry.save_as_incomplete
      redirect_to loan_url(@loan_entry.loan)
    when 'State Aid Calculation'
      @loan_entry.save_as_incomplete
      redirect_to edit_loan_state_aid_calculation_url(@loan_entry.loan, variant: StateAidCalculationVariant::LoanEntry)
    else
      if @loan_entry.save
        if @loan_entry.complete?
          redirect_to complete_loan_entry_url(@loan_entry.loan)
        else
          redirect_to loan_url(@loan_entry.loan)
        end
      else
        render :new
      end
    end
  end

  def complete
  end

  private
  def verify_create_permission
    enforce_create_permission(LoanEntry)
  end

  def load_loan
    @loan = current_lender.loans.find(params[:loan_id])
  end

end
