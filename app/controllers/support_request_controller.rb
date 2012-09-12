class SupportRequestController < ApplicationController

  def new
    @support_request = SupportRequest.new
  end

  def create
    @support_request = SupportRequest.new(params[:support_request].merge(user: current_user))
    if @support_request.valid?
      SupportRequestMailer.notification_email(@support_request, browser, operating_system).deliver
      redirect_to root_url, notice: 'Your support request has been sent'
    else
      render :new
    end
  end

  private

  def browser
    [ user_agent.browser, user_agent.version].join(', ')
  end

  def operating_system
    [ user_agent.platform, user_agent.os].join(', ')
  end

  def user_agent
    @user_agent ||= UserAgent.parse(request.env['HTTP_USER_AGENT'])
  end

end
