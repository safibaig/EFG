class AccountDisabledController < ApplicationController

  skip_before_filter :redirect_disabled_user
  before_filter :redirect_active_user

  def show
  end

  private

  def redirect_active_user
    redirect_to root_path unless current_user.disabled?
  end

end
