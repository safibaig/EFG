class PhasesController < ApplicationController
  before_filter :verify_view_permission, only: [:index]
  before_filter :verify_create_permission, only: [:new, :create]
  before_filter :verify_update_permission, only: [:edit, :update, :activate, :deactivate]

  def index
    @phases = Phase.order('name ASC')
  end

  def new
    @phase = Phase.new
  end

  def create
    @phase = Phase.new(params[:phase])
    @phase.created_by = current_user
    @phase.modified_by = current_user

    save = -> { @phase.save }

    if audit(AdminAudit::PhaseCreated, @phase, &save)
      redirect_to phases_url
    else
      render :new
    end
  end

  def edit
    @phase = Phase.find(params[:id])
  end

  def update
    @phase = Phase.find(params[:id])
    @phase.modified_by = current_user

    update = -> { @phase.update_attributes(params[:phase]) }

    if audit(AdminAudit::PhaseEdited, @phase, &update)
      redirect_to phases_url
    else
      render :edit
    end
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

    def audit(event, object, &action)
      ActiveRecord::Base.transaction do
        success = action.call
        AdminAudit.log(event, object, current_user) if success
        success
      end
    end
end
