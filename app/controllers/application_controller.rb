class ApplicationController < ActionController::Base
  include Canable::Enforcers

  protect_from_forgery

  before_filter :authenticate_user!
  before_filter :redirect_disabled_user
  before_filter :redirect_locked_user

  before_filter do
    headers["X-Frame-Options"] = "SAMEORIGIN"
    headers["X-Content-Type-Options"] = "nosniff"
    headers["X-XSS-Protection"] = "1; mode=block"
  end

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

  def stream_response(enumerator, filename, content_type = "text/csv", disposition="attachment", last_modified = Time.now)
    self.response.headers["Content-Type"] = content_type
    self.response.headers["Content-Disposition"] = "#{disposition}; filename=\"#{filename}\""
    self.response.headers["Last-Modified"] = last_modified.ctime.to_s
    self.response_body = enumerator
  end

  def self.rescue_from_incorrect_loan_state_error
    rescue_from LoanStateTransition::IncorrectLoanState do |exception|
      ExceptionNotifier::Notifier.exception_notification(request.env, exception).deliver
      redirect_to loan_url(@loan)
    end
  end
end
