class ApplicationController < ActionController::Base
  include Canable::Enforcers

  protect_from_forgery

  before_filter :authenticate_user!
  before_filter :redirect_disabled_user

  def current_lender
    current_user.lender
  end

  # if logged in user is disabled and not trying to log out...
  def redirect_disabled_user
    if signed_in? && current_user.disabled? && !devise_controller?
      redirect_to account_disabled_path and return
    end
  end
end
