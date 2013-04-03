class AgreedDrawsController < ApplicationController
  before_filter :verify_create_permission
  before_filter :load_loan

  def new
    @agreed_draw = AgreedDraw.new(@loan)
  end

  def create
    @agreed_draw = AgreedDraw.new(@loan)
    @agreed_draw.attributes = params[:agreed_draw]
    @agreed_draw.created_by = current_user

    if @agreed_draw.save
      redirect_to loan_url(@loan)
    else
      render :new
    end
  end

  private
    def load_loan
      @loan = current_lender.loans.guaranteed.find(params[:loan_id])
    end

    def verify_create_permission
      enforce_create_permission(AgreedDraw)
    end
end
