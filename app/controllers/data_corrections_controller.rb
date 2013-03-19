class DataCorrectionsController < ApplicationController
  TYPES = {
    'demanded_amount' => DemandedAmountDataCorrectionPresenter,
    'sortcode' => SortcodeDataCorrectionPresenter
  }

  before_filter :verify_create_permission
  before_filter :load_loan

  def index
  end

  def new
    @presenter = presenter_class.new
  end

  def create
    @presenter = presenter_class.new(params[:data_correction])
    @presenter.created_by = current_user
    @presenter.loan = @loan

    if @presenter.save
      redirect_to loan_url(@loan)
    else
      render :new
    end
  end

  private
    def load_loan
      @loan = current_lender.loans.correctable.find(params[:loan_id])
    end

    def presenter_class
      TYPES.fetch(params[:type])
    end

    def verify_create_permission
      enforce_create_permission(DataCorrection)
    end
end
