require 'memorable_password'

class AuditorUsersController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]
  before_filter :verify_update_permission, only: [:edit, :update]
  before_filter :verify_view_permission, only: [:index, :show]

  def index
    @users = AuditorUser.scoped
  end

  def show
    @user = AuditorUser.find(params[:id])
  end

  def new
    @user = AuditorUser.new
  end

  def create
    @user = AuditorUser.new(params[:auditor_user])
    @user.created_by = current_user
    @user.modified_by = current_user
    password = MemorablePassword.generate
    @user.password = @user.password_confirmation = password

    if @user.save
      flash[:notice] = "The password has been set to: #{password}"
      redirect_to auditor_user_url(@user)
    else
      render :new
    end
  end

  def edit
    @user = AuditorUser.find(params[:id])
  end

  def update
    @user = AuditorUser.find(params[:id])
    @user.attributes = params[:auditor_user]
    @user.locked = params[:auditor_user][:locked]
    @user.modified_by = current_user

    if @user.save
      redirect_to auditor_user_url(@user)
    else
      render :edit
    end
  end

  private
    def verify_create_permission
      enforce_create_permission(AuditorUser)
    end

    def verify_update_permission
      enforce_update_permission(AuditorUser)
    end

    def verify_view_permission
      enforce_view_permission(AuditorUser)
    end
end
