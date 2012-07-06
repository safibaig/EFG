class InvoicesController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :select_loans, :create]

  def show
    @invoice = Invoice.find(params[:id])
    enforce_view_permission(@invoice)
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

  private
  def verify_create_permission
    enforce_create_permission(Invoice)
  end
end
