class DocumentsController < ApplicationController

  respond_to :pdf

  def state_aid_letter
    loan = current_lender.loans.find(params[:id])
    pdf = StateAidLetter.new(loan)

    send_data(pdf.render, filename: pdf.filename, type: "application/pdf", disposition: "inline")
  end

  def information_declaration
    loan = current_lender.loans.find(params[:id])
    pdf = InformationDeclaration.new(loan)

    send_data(pdf.render, filename: pdf.filename, type: "application/pdf", disposition: "inline")
  end

  def data_protection_declaration
    pdf = DataProtectionDeclaration.new

    send_data(pdf.render, filename: pdf.filename, type: "application/pdf", disposition: "inline")
  end

end
