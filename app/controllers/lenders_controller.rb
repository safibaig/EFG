class LendersController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]
  before_filter :verify_update_permission, only: [:edit, :update, :activate, :deactivate]
  before_filter :verify_view_permission, only: [:index]

  def index
    @lenders = Lender.includes(:active_lending_limits).order_by_name
  end

  def new
    @lender = Lender.new
  end

  def create
    @lender = Lender.new(params[:lender])
    @lender.created_by = current_user
    @lender.modified_by = current_user

    if @lender.save
      AdminAudit.log(AdminAudit::LenderCreated, @lender, current_user)
      redirect_to lenders_url
    else
      render :new
    end
  end

  def edit
    @lender = Lender.find(params[:id])
  end

  def update
    @lender = Lender.find(params[:id])
    @lender.attributes = params[:lender]
    @lender.modified_by = current_user

    if @lender.save
      AdminAudit.log(AdminAudit::LenderEdited, @lender, current_user)
      redirect_to lenders_url
    else
      render :edit
    end
  end

  def activate
    @lender = Lender.find(params[:id])
    @lender.modified_by = current_user
    @lender.activate!
    AdminAudit.log(AdminAudit::LenderEnabled, @lender, current_user)
    redirect_to lenders_url
  end

  def deactivate
    @lender = Lender.find(params[:id])
    @lender.modified_by = current_user
    @lender.deactivate!
    AdminAudit.log(AdminAudit::LenderDisabled, @lender, current_user)
    redirect_to lenders_url
  end

  private
    def verify_create_permission
      enforce_create_permission(Lender)
    end

    def verify_update_permission
      enforce_update_permission(Lender)
    end

    def verify_view_permission
      enforce_view_permission(Lender)
    end
end
