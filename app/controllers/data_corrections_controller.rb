class DataCorrectionsController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]
  before_filter :load_loan

  def new
    @data_correction = @loan.data_corrections.new
  end

  def create
    @data_correction = @loan.data_corrections.new(params[:data_correction])
    @data_correction.date_of_change = Date.current
    @data_correction.created_by = current_user
    @data_correction.modified_date = Date.current

    if @data_correction.save_and_update_loan
      redirect_to loan_url(@loan)
    else
      render :new
    end
  end

  private
    def load_loan
      @loan = current_lender.loans.correctable.find(params[:loan_id])
    end

    def verify_create_permission
      enforce_create_permission(LoanChange)
    end
end
