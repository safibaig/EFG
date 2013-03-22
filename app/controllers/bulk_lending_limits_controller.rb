class BulkLendingLimitsController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]

  def new
    @phase = BulkLendingLimits.new
  end

  def create
    @phase = BulkLendingLimits.new(params[:bulk_lending_limits])
    @phase.created_by = current_user

    if @phase.save
      redirect_to phases_path
    else
      render :new
    end
  end

  private

    def verify_create_permission
      enforce_create_permission(Phase)
      enforce_create_permission(LendingLimit)
    end
end
