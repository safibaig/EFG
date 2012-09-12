class SupportRequestController < ApplicationController

  def new
    @support_request = SupportRequest.new
  end

  def create
    @support_request = SupportRequest.new(params[:support_request].merge(user: current_user))
    if @support_request.valid?
      SupportRequestMailer.notification_email(@support_request, nil, nil).deliver
      redirect_to root_url, notice: 'Your support request has been sent'
    else
      render :new
    end
  end

end
