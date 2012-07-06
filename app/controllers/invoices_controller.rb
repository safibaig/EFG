class InvoicesController < ApplicationController
  # TODO: Access Control.

  def show
    @invoice = Invoice.find(params[:id])
  end

  def new
    @invoice = Invoice.new
  end

  def select_loans
    @invoice = Invoice.new(params[:invoice])

    if @invoice.invalid?(:details)
      render :new
    end
  end

  def create
    @invoice = Invoice.new(params[:invoice])
    @invoice.created_by = current_user

    if @invoice.save
      redirect_to invoice_url(@invoice)
    else
      render :select_loans
    end
  end
end
