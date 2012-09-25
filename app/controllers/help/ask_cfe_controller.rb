class Help::AskCfeController < ApplicationController
  def new
    @ask_cfe = AskCfe.new
  end

  def create
    @ask_cfe = AskCfe.new(params[:ask_cfe])
    @ask_cfe.user = current_user

    if @ask_cfe.valid?
      @ask_cfe.deliver
    else
      render :new
    end
  end
end
