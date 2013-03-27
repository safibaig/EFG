class LoanChangesController < ApplicationController
  TYPES = {
    'lump_sum_repayment' => LumpSumRepaymentLoanChangePresenter,
    'repayment_duration' => RepaymentDurationLoanChangePresenter,
    'reprofile_draws' => ReprofileDrawsLoanChangePresenter
  }

  before_filter :verify_create_permission
  before_filter :load_loan

  def index
  end

  def new
    @presenter = presenter_class.new(@loan)
  end

  def create
    @presenter = presenter_class.new(@loan)
    @presenter.attributes = params[:loan_change]
    @presenter.created_by = current_user

    if @presenter.save
      redirect_to loan_url(@loan)
    else
      render :new
    end
  end

  private
    def load_loan
      @loan = current_lender.loans.changeable.find(params[:loan_id])
    end

    def presenter_class
      TYPES.fetch(params[:type])
    end

    def verify_create_permission
      enforce_create_permission(LoanChange)
    end
end
