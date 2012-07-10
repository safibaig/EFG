class RecoveriesController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]
  before_filter :load_loan

  def new
    @recovery = RecoveryPresenter.new(@loan)
  end

  def create
    @recovery = RecoveryPresenter.new(@loan)
    @recovery.attributes = params[:recovery]
    @recovery.created_by = current_user

    if @recovery.save
      redirect_to loan_url(@loan)
    else
      render :new
    end
  end

  private
    def load_loan
      @loan = current_lender.loans.find(params[:loan_id])
    end

    def verify_create_permission
      enforce_create_permission(Recovery)
    end
end
