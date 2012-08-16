class InvoicesController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :select_loans, :create]

  def show
    enforce_view_permission(Invoice)
    @invoice = Invoice.find(params[:id])
  end

  def new
    @invoice = Invoice.new
  end

  def select_loans
    @invoice = Invoice.new(params[:invoice])

    if @invoice.invalid?(:details)
      render :new and return
    end

    respond_to do |format|
      format.html
      format.csv do
        filename = "loans_to_settle_#{@invoice.lender.name.parameterize}_#{Date.today.to_s(:db)}.csv"
        csv_export = InvoiceCsvExport.new(@invoice.demanded_loans)
        send_data(csv_export.generate, type: 'text/csv', filename: filename, disposition: 'attachment')
      end
    end
  end

  def create
    @invoice = Invoice.new(params[:invoice])
    @invoice.created_by = current_user

    if @invoice.save_and_settle_loans
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
