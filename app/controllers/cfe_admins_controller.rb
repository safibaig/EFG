class CfeAdminsController < UsersController
  def index
    @users = CfeAdmin.where(disabled: params[:disabled])
      .paginate(per_page: 100, page: params[:page])
  end

  def show
  end

  def new
    @user = CfeAdmin.new
  end

  def create
    @user = CfeAdmin.new(params[:cfe_admin])
    @user.created_by = current_user
    @user.modified_by = current_user

    if @user.save
      AdminAudit.log(AdminAudit::UserCreated, @user, current_user)
      @user.send_new_account_notification
      flash[:notice] = I18n.t('manage_users.new_account_email_sent', email: @user.email)
      redirect_to cfe_admin_url(@user)
    else
      render :new
    end
  end

  def edit
  end

  def update
    @user.attributes = params[:cfe_admin]
    @user.modified_by = current_user

    if @user.save
      AdminAudit.log(AdminAudit::UserEdited, @user, current_user)
      redirect_to cfe_admin_url(@user)
    else
      render :edit
    end
  end

  def reset_password
    render :edit and return unless @user.valid?
    @user.send_new_account_notification
    redirect_to :back, notice: I18n.t('manage_users.reset_password_sent', email: @user.email)
  end

  def unlock
    @user.unlock!
    AdminAudit.log(AdminAudit::UserUnlocked, @user, current_user)
    redirect_to cfe_admin_url(@user)
  end

  def disable
    @user.disable!
    AdminAudit.log(AdminAudit::UserDisabled, @user, current_user)
    redirect_to cfe_admin_url(@user)
  end

  def enable
    @user.enable!
    AdminAudit.log(AdminAudit::UserEnabled, @user, current_user)
    redirect_to cfe_admin_url(@user)
  end

  private
    def find_user
      @user = CfeAdmin.find(params[:id])
    end

    def user_class
      CfeAdmin
    end
end
