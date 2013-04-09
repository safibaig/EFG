class LoanOffersController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]
  before_filter :load_loan, only: [:new, :create]
  before_filter :redirect_if_lending_limit_unavailable, only: [:new, :create]
  rescue_from_incorrect_loan_state_error

  def new
    @loan_offer = LoanOffer.new(@loan)
  end

  def create
    @loan_offer = LoanOffer.new(@loan)
    @loan_offer.attributes = params[:loan_offer]
    @loan_offer.modified_by = current_user

    if @loan_offer.save
      redirect_to loan_url(@loan_offer.loan)
    else
      render :new
    end
  end

  private
  def verify_create_permission
    enforce_create_permission(LoanOffer)
  end

  def load_loan
    @loan = current_lender.loans.find(params[:loan_id])
  end

  def redirect_if_lending_limit_unavailable
    if @loan.lending_limit.unavailable?
      redirect_to new_loan_update_lending_limit_url(@loan)
      return
    end
  end
end
