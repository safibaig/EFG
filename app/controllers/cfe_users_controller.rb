require 'memorable_password'

class CfeUsersController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]
  before_filter :verify_update_permission, only: [:edit, :update]
  before_filter :verify_view_permission, only: [:index, :show]

  def index
    @users = CfeUser.scoped
  end

  def show
    @user = CfeUser.find(params[:id])
  end

  def new
    @user = CfeUser.new
  end

  def create
    @user = CfeUser.new(params[:cfe_user])
    password = MemorablePassword.generate
    @user.password = @user.password_confirmation = password

    if @user.save
      flash[:notice] = "The password has been set to: #{password}"
      redirect_to cfe_user_url(@user)
    else
      render :new
    end
  end

  def edit
    @user = CfeUser.find(params[:id])
  end

  def update
    @user = CfeUser.find(params[:id])
    @user.attributes = params[:cfe_user]
    @user.locked = params[:cfe_user][:locked]

    if @user.save
      redirect_to cfe_user_url(@user)
    else
      render :edit
    end
  end

  private
    def verify_create_permission
      enforce_create_permission(CfeUser)
    end

    def verify_update_permission
      enforce_update_permission(CfeUser)
    end

    def verify_view_permission
      enforce_view_permission(CfeUser)
    end
end
