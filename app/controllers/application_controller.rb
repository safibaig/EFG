class ApplicationController < ActionController::Base
  include Canable::Enforcers

  protect_from_forgery

  before_filter :authenticate_user!
  before_filter :redirect_disabled_user
  before_filter :redirect_locked_user

  helper_method :current_lender

  def current_lender
    current_user.lender
  end

  # if logged in user is disabled and not trying to log out...
  def redirect_disabled_user
    if signed_in? && current_user.disabled? && !devise_controller?
      redirect_to account_disabled_url and return
    end
  end

  # if logged in user is locked and not trying to log out...
  def redirect_locked_user
    if signed_in? && current_user.locked? && !devise_controller?
      redirect_to account_locked_url and return
    end
  end

  def track_first_login
    if current_user && current_user.sign_in_count == 1
      current_user.user_audits.create!(
        function: UserAudit::INITIAL_LOGIN,
        modified_by: current_user,
        password: current_user.encrypted_password
      )
      AdminAudit.log(AdminAudit::UserInitialLogin, current_user, current_user)
    end
  end

end
