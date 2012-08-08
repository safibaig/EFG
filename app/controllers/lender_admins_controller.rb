require 'memorable_password'

class LenderAdminsController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]
  before_filter :verify_update_permission, only: [:edit, :update]
  before_filter :verify_view_permission, only: [:index, :show]

  def index
    @users = LenderAdmin.includes(:lender)
  end

  def show
    @user = LenderAdmin.find(params[:id])
  end

  def new
    @user = LenderAdmin.new
  end

  def create
    @user = LenderAdmin.new(params[:lender_admin])
    @user.lender = Lender.find(params[:lender_admin][:lender_id])
    password = MemorablePassword.generate
    @user.password = @user.password_confirmation = password

    if @user.save
      flash[:notice] = "The password has been set to: #{password}"
      redirect_to lender_admin_url(@user)
    else
      render :new
    end
  end

  def edit
    @user = LenderAdmin.find(params[:id])
  end

  def update
    @user = LenderAdmin.find(params[:id])

    if @user.update_attributes(params[:lender_admin])
      redirect_to lender_admin_url(@user)
    else
      render :edit
    end
  end

  private
    def verify_create_permission
      enforce_create_permission(LenderAdmin)
    end

    def verify_update_permission
      enforce_update_permission(LenderAdmin)
    end

    def verify_view_permission
      enforce_view_permission(LenderAdmin)
    end
end
