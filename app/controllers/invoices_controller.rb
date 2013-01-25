class InvoicesController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :select_loans, :create]

  def show
    enforce_view_permission(Invoice)
    @invoice = Invoice.find(params[:id])
  end

  def new
    @invoice = InvoiceReceived.new
  end

  def select_loans
    @invoice = InvoiceReceived.new
    @invoice.attributes = params[:invoice]

    if @invoice.invalid?(:details)
      render :new and return
    end

    respond_to do |format|
      format.html
      format.csv do
        filename = "loans_to_settle_#{@invoice.lender.name.parameterize}_#{Date.today.to_s(:db)}.csv"
        csv_export = LoansToSettleCsvExport.new(@invoice.loans)
        stream_response(csv_export, filename)
      end
    end
  end

  def create
    @invoice = InvoiceReceived.new
    @invoice.attributes = params[:invoice]
    @invoice.creator = current_user

    if @invoice.save
      redirect_to invoice_url(@invoice.invoice)
    else
      render :select_loans
    end
  end

  private
  def verify_create_permission
    enforce_create_permission(Invoice)
  end
end
