module UserManagementHelper

  def set_password_options(user)
    if user.email.present? && !user.has_password?
      if user.password_reset_pending?
        render "user_management/reset_password_email_sent", user: user
      else
        render "user_management/password_not_set", user: user
      end
    end
  end

  def set_email_options(user)
    if user.email.blank?
      render "user_management/email_not_set", user: user
    end
  end

  def time_left_to_set_password(user)
    end_time = user.reset_password_sent_at + User.reset_password_within
    distance_of_time_in_words(Time.now, end_time)
  end

end
