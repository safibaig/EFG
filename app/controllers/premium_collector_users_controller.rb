require 'memorable_password'

class PremiumCollectorUsersController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]
  before_filter :verify_update_permission, only: [:edit, :update]
  before_filter :verify_view_permission, only: [:index, :show]

  def index
    @users = PremiumCollectorUser.scoped
  end

  def show
    @user = PremiumCollectorUser.find(params[:id])
  end

  def new
    @user = PremiumCollectorUser.new
  end

  def create
    @user = PremiumCollectorUser.new(params[:premium_collector_user])
    password = MemorablePassword.generate
    @user.password = @user.password_confirmation = password

    if @user.save
      flash[:notice] = "The password has been set to: #{password}"
      redirect_to premium_collector_user_url(@user)
    else
      render :new
    end
  end

  def edit
    @user = PremiumCollectorUser.find(params[:id])
  end

  def update
    @user = PremiumCollectorUser.find(params[:id])
    @user.attributes = params[:premium_collector_user]
    @user.locked = params[:premium_collector_user][:locked]

    if @user.save
      redirect_to premium_collector_user_url(@user)
    else
      render :edit
    end
  end

  private
    def verify_create_permission
      enforce_create_permission(PremiumCollectorUser)
    end

    def verify_update_permission
      enforce_update_permission(PremiumCollectorUser)
    end

    def verify_view_permission
      enforce_view_permission(PremiumCollectorUser)
    end
end
