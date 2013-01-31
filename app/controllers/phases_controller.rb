class PhasesController < ApplicationController
  before_filter :verify_view_permission, only: [:index]
  before_filter :verify_create_permission, only: [:new, :create]
  before_filter :verify_update_permission, only: [:edit, :update, :activate, :deactivate]

  def index
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  private
    def verify_create_permission
      enforce_create_permission(Phase)
    end

    def verify_update_permission
      enforce_update_permission(Phase)
    end

    def verify_view_permission
      enforce_view_permission(Phase)
    end
end
