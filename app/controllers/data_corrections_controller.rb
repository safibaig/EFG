class DataCorrectionsController < ApplicationController
  TYPES = {
    'business_name' => BusinessNameDataCorrection,
    'demanded_amount' => DemandedAmountDataCorrection,
    'sortcode' => SortcodeDataCorrection
  }

  before_filter :verify_create_permission
  before_filter :load_loan
  before_filter :load_presenter, only: [:new, :create]

  def index
  end

  def new
  end

  def create
    @presenter.attributes = params[:data_correction]
    @presenter.created_by = current_user

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

    def load_presenter
      klass = TYPES[params[:type]]

      if klass
        @presenter = klass.new(@loan)
      else
        redirect_to action: :index
      end
    end

    def verify_create_permission
      enforce_create_permission(DataCorrection)
    end
end
