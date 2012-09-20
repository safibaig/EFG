class PremiumCollectorUsersController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]
  before_filter :verify_update_permission, only: [:edit, :update, :reset_password]
  before_filter :verify_view_permission, only: [:index, :show]

  before_filter :find_user, only: [:show, :edit, :update, :reset_password]

  def index
    @users = PremiumCollectorUser.paginate(per_page: 100, page: params[:page])
  end

  def show
  end

  def new
    @user = PremiumCollectorUser.new
  end

  def create
    @user = PremiumCollectorUser.new(params[:premium_collector_user])
    @user.created_by = current_user
    @user.modified_by = current_user

    if @user.save
      AdminAudit.log(AdminAudit::UserCreated, @user, current_user)
      @user.send_new_account_notification
      flash[:notice] = I18n.t('manage_users.new_account_email_sent', email: @user.email)
      redirect_to premium_collector_user_url(@user)
    else
      render :new
    end
  end

  def edit
  end

  def update
    @user.attributes = params[:premium_collector_user]
    @user.locked = params[:premium_collector_user][:locked]
    @user.disabled = params[:premium_collector_user][:disabled]
    @user.modified_by = current_user

    if @user.save
      AdminAudit.log(AdminAudit::UserEdited, @user, current_user)
      redirect_to premium_collector_user_url(@user)
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
      enforce_create_permission(PremiumCollectorUser)
    end

    def verify_update_permission
      enforce_update_permission(PremiumCollectorUser)
    end

    def verify_view_permission
      enforce_view_permission(PremiumCollectorUser)
    end

    def find_user
      @user = PremiumCollectorUser.find(params[:id])
    end
end
