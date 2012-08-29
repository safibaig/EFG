class LoanAllocationsController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]
  before_filter :verify_update_permission, only: [:edit, :update]
  before_filter :verify_view_permission, only: [:index]
  before_filter :loan_lender

  def index
    @loan_allocations = @lender.loan_allocations
  end

  def new
    @loan_allocation = @lender.loan_allocations.new
  end

  def create
    @loan_allocation = @lender.loan_allocations.new
    @loan_allocation.attributes = params[:loan_allocation]
    @loan_allocation.modified_by = current_user

    if @loan_allocation.save
      redirect_to lender_loan_allocations_url(@lender)
    else
      render :new
    end
  end

  def edit
    @loan_allocation = @lender.loan_allocations.find(params[:id])
  end

  def update
    @loan_allocation = @lender.loan_allocations.find(params[:id])
    @loan_allocation.attributes = params[:loan_allocation].slice(:allocation, :description)
    @loan_allocation.modified_by = current_user

    if @loan_allocation.save
      redirect_to lender_loan_allocations_url(@lender)
    else
      render :edit
    end
  end

  private
    def loan_lender
      @lender = Lender.find(params[:lender_id])
    end

    def verify_create_permission
      enforce_create_permission(LoanAllocation)
    end

    def verify_update_permission
      enforce_update_permission(LoanAllocation)
    end

    def verify_view_permission
      enforce_view_permission(LoanAllocation)
    end
end
