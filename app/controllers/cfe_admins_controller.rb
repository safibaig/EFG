require 'memorable_password'

class CfeAdminsController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]
  before_filter :verify_update_permission, only: [:edit, :update]
  before_filter :verify_view_permission, only: [:index, :show]

  def index
    @users = CfeAdmin.scoped
  end

  def show
    @user = CfeAdmin.find(params[:id])
  end

  def new
    @user = CfeAdmin.new
  end

  def create
    @user = CfeAdmin.new(params[:cfe_admin])
    @user.created_by = current_user
    @user.modified_by = current_user
    password = MemorablePassword.generate
    @user.password = @user.password_confirmation = password

    if @user.save
      flash[:notice] = "The password has been set to: #{password}"
      redirect_to cfe_admin_url(@user)
    else
      render :new
    end
  end

  def edit
    @user = CfeAdmin.find(params[:id])
  end

  def update
    @user = CfeAdmin.find(params[:id])
    @user.attributes = params[:cfe_admin]
    @user.locked = params[:cfe_admin][:locked]
    @user.modified_by = current_user

    if @user.save
      redirect_to cfe_admin_url(@user)
    else
      render :edit
    end
  end

  private
    def verify_create_permission
      enforce_create_permission(CfeAdmin)
    end

    def verify_update_permission
      enforce_update_permission(CfeAdmin)
    end

    def verify_view_permission
      enforce_view_permission(CfeAdmin)
    end
end
