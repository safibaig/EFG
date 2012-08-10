require 'memorable_password'

class LenderAdminsController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]
  before_filter :verify_update_permission, only: [:edit, :update]
  before_filter :verify_view_permission, only: [:index, :show]

  def index
    @users = LenderAdmin.includes(:lender).paginate(per_page: 100, page: params[:page])
  end

  def show
    @user = LenderAdmin.find(params[:id])
  end

  def new
    @user = LenderAdmin.new
  end

  def create
    @user = LenderAdmin.new(params[:lender_admin])
    @user.created_by = current_user
    @user.lender = Lender.find(params[:lender_admin][:lender_id])
    @user.modified_by = current_user
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
    @user.attributes = params[:lender_admin]
    @user.locked = params[:lender_admin][:locked]
    @user.modified_by = current_user

    if @user.save
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
