class LoanOffersController < ApplicationController
  def new
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_offer = LoanOffer.new(@loan)
  end

  def create
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_offer = LoanOffer.new(@loan, params[:loan_offer])
    @loan_offer.save
    redirect_to loan_url(@loan_offer.loan)
  end
end
