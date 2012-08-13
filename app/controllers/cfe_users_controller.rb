require 'memorable_password'

class CfeUsersController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]
  before_filter :verify_update_permission, only: [:edit, :update, :reset_password]
  before_filter :verify_view_permission, only: [:index, :show]

  before_filter :find_user, only: [:show, :edit, :update, :reset_password]

  def index
    @users = CfeUser.paginate(per_page: 100, page: params[:page])
  end

  def show
  end

  def new
    @user = CfeUser.new
  end

  def create
    @user = CfeUser.new(params[:cfe_user])
    @user.created_by = current_user
    @user.modified_by = current_user
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
  end

  def update
    @user.attributes = params[:cfe_user]
    @user.locked = params[:cfe_user][:locked]
    @user.modified_by = current_user

    if @user.save
      redirect_to cfe_user_url(@user)
    else
      render :edit
    end
  end

  def reset_password
    render :edit and return unless @user.valid?
    @user.send_new_account_notification
    redirect_to :back, notice: I18n.t('manage_users.reset_password_sent', email: @user.email)
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

    def find_user
      @user = CfeUser.find(params[:id])
    end
end
