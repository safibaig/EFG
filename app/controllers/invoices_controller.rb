class InvoicesController < ApplicationController
  # TODO: Access Control.

  def new
    @invoice = Invoice.new
  end

  def new2
    @invoice = Invoice.new(params[:invoice])
  end

  def create
    @invoice = Invoice.new(params[:invoice])
    @invoice.created_by = current_user

    if @invoice.save
      redirect_to root_url
    else
      render :new
    end
  end
end
