class PhasesWithLendingLimitsController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]

  def new
    @phase = PhaseWithLendingLimits.new
  end

  def create
    
  end

  private

    def verify_create_permission
      enforce_create_permission(Phase)
      enforce_create_permission(LendingLimit)
    end
end
