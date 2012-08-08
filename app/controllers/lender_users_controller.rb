require 'memorable_password'

class LenderUsersController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]
  before_filter :verify_update_permission, only: [:edit, :update]
  before_filter :verify_view_permission, only: [:index, :show]

  def index
    @users = current_lender.lender_users.scoped
  end

  def show
    @user = current_lender.lender_users.find(params[:id])
  end

  def new
    @user = current_lender.lender_users.new
  end

  def create
    @user = current_lender.lender_users.new(params[:lender_user])
    @user.created_by = current_user
    @user.modified_by = current_user
    password = MemorablePassword.generate
    @user.password = @user.password_confirmation = password

    if @user.save
      flash[:notice] = "The password has been set to: #{password}"
      redirect_to lender_user_url(@user)
    else
      render :new
    end
  end

  def edit
    @user = current_lender.lender_users.find(params[:id])
  end

  def update
    @user = current_lender.lender_users.find(params[:id])
    @user.attributes = params[:lender_user]
    @user.locked = params[:lender_user][:locked]
    @user.modified_by = current_user

    if @user.save
      redirect_to lender_user_url(@user)
    else
      render :edit
    end
  end

  private
    def verify_create_permission
      enforce_create_permission(LenderUser)
    end

    def verify_update_permission
      enforce_update_permission(LenderUser)
    end

    def verify_view_permission
      enforce_view_permission(LenderUser)
    end
end
