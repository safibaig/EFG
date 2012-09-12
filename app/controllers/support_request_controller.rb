class SupportRequestController < ApplicationController

  def new
    @support_request = SupportRequest.new
  end

  def create
    @support_request = SupportRequest.new(params[:support_request])
    if @support_request.valid?
      # send email
      redirect_to :back, notice: 'Your support request has been sent'
    else
      render :new
    end
  end

end
