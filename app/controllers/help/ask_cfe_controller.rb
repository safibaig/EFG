class Help::AskCfeController < ApplicationController
  before_filter :verify_create_permission

  def new
    @ask_cfe = AskCfe.new
  end

  def create
    @ask_cfe = AskCfe.new(params[:ask_cfe])
    @ask_cfe.user = current_user
    @ask_cfe.user_agent = UserAgent.parse(request.env['HTTP_USER_AGENT'])

    if @ask_cfe.valid?
      @ask_cfe.deliver
    else
      render :new
    end
  end

  private
    def verify_create_permission
      enforce_create_permission(AskCfe)
    end
end
