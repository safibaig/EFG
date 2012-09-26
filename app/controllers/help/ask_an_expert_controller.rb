class Help::AskAnExpertController < ApplicationController
  before_filter :verify_create_permission
  before_filter :load_experts

  def new
    @ask_an_expert = AskAnExpert.new
  end

  def create
    @experts = current_lender.experts
    @ask_an_expert = AskAnExpert.new(params[:ask_an_expert])
    @ask_an_expert.experts = @experts
    @ask_an_expert.user = current_user

    if @ask_an_expert.valid?
      @ask_an_expert.deliver
    else
      render :new
    end
  end

  private
    def load_experts
      @experts = current_lender.experts
    end

    def verify_create_permission
      enforce_create_permission(AskAnExpert)
    end
end
