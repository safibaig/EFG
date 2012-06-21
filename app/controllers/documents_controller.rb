class DocumentsController < ApplicationController

  respond_to :pdf

  def state_aid_letter
    loan = current_lender.loans.find(params[:id])
    pdf = StateAidLetter.new(loan)
    send_data(pdf.render, filename: "state_aid_letter.pdf", type: "application/pdf", disposition: "inline")
  end

end
