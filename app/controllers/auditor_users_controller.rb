class AuditorUsersController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]
  before_filter :verify_update_permission, only: [:edit, :update, :reset_password]
  before_filter :verify_view_permission, only: [:index, :show]

  before_filter :find_user, only: [:show, :edit, :update, :reset_password]

  def index
    @users = AuditorUser.paginate(per_page: 100, page: params[:page])
  end

  def show
  end

  def new
    @user = AuditorUser.new
  end

  def create
    @user = AuditorUser.new(params[:auditor_user])
    @user.created_by = current_user
    @user.modified_by = current_user

    if @user.save
      @user.send_new_account_notification
      flash[:notice] = I18n.t('manage_users.new_account_email_sent', email: @user.email)
      redirect_to auditor_user_url(@user)
    else
      render :new
    end
  end

  def edit
  end

  def update
    @user.attributes = params[:auditor_user]
    @user.locked = params[:auditor_user][:locked]
    @user.modified_by = current_user

    if @user.save
      redirect_to auditor_user_url(@user)
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
      enforce_create_permission(AuditorUser)
    end

    def verify_update_permission
      enforce_update_permission(AuditorUser)
    end

    def verify_view_permission
      enforce_view_permission(AuditorUser)
    end

    def find_user
      @user = AuditorUser.find(params[:id])
    end

end
