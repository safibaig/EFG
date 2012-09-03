class AccountLockedController < ApplicationController

  skip_before_filter :redirect_locked_user
  before_filter :redirect_active_user

  def show
  end

  private

  def redirect_active_user
    redirect_to root_url unless current_user.locked?
  end

end
