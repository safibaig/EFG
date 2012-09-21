class ChangePasswordController < ApplicationController

  def edit
  end

  def update
    current_user.password = params[user_type][:password]
    current_user.password_confirmation = params[user_type][:password_confirmation]
    sign_in(current_user, bypass: true) # refresh session credentials so user stays logged in

    if current_user.save
      track_password_change
      redirect_to root_url, notice: 'Your password has been successfully changed'
    else
      render :edit
    end
  end

  private

  def user_type
    current_user.class.to_s.underscore
  end

  def track_password_change
    current_user.user_audits.create!(
      function: UserAudit::PASSWORD_CHANGED,
      modified_by: current_user,
      password: current_user.encrypted_password
    )
  end

end
