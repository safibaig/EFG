class DocumentsController < ApplicationController

  respond_to :pdf

  def state_aid_letter
    enforce_view_permission(StateAidLetter)
    loan = current_lender.loans.find(params[:id])
    pdf = StateAidLetter.new(loan)

    send_data(pdf.render, filename: pdf.filename, type: "application/pdf", disposition: "inline")
  end

  def information_declaration
    enforce_view_permission(InformationDeclaration)
    loan = current_lender.loans.find(params[:id])
    pdf = InformationDeclaration.new(loan)

    send_data(pdf.render, filename: pdf.filename, type: "application/pdf", disposition: "inline")
  end

  def data_protection_declaration
    enforce_view_permission(DataProtectionDeclaration)
    pdf = DataProtectionDeclaration.new

    send_data(pdf.render, filename: pdf.filename, type: "application/pdf", disposition: "inline")
  end

end
