class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_user!

  def current_lender
    current_user.lender
  end
end
