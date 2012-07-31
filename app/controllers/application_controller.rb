class ApplicationController < ActionController::Base
  include Canable::Enforcers

  protect_from_forgery

  before_filter :authenticate_user!
  
  helper_method :current_lender

  def current_lender
    current_user.lender
  end
end
