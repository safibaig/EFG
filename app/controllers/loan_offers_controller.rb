class LoanOffersController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]
  rescue_from_incorrect_loan_state_error

  def new
    @loan = current_lender.loans.find(params[:loan_id])

    if @loan.lending_limit.unavailable?
      render 'unavailable_lending_limit'
      return
    end

    @loan_offer = LoanOffer.new(@loan)
  end

  def create
    @loan = current_lender.loans.find(params[:loan_id])
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
end
