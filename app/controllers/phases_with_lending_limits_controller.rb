class PhasesWithLendingLimitsController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]

  def new
    @phase = PhaseWithLendingLimits.new
  end

  def create
    @phase = PhaseWithLendingLimits.new(params[:phase])
    @phase.created_by = current_user

    if @phase.save
      redirect_to phases_path
    end
  end

  private

    def verify_create_permission
      enforce_create_permission(Phase)
      enforce_create_permission(LendingLimit)
    end
end
