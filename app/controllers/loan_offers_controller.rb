class LoanOffersController < ApplicationController
  def new
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_offer = LoanOffer.new(@loan)
    enforce_create_permission(@loan_offer)
  end

  def create
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_offer = LoanOffer.new(@loan)
    enforce_create_permission(@loan_offer)
    @loan_offer.attributes = params[:loan_offer]

    if @loan_offer.save
      redirect_to loan_url(@loan_offer.loan)
    else
      render :new
    end
  end
end
