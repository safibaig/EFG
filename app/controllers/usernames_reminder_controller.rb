class UsernamesReminderController < ApplicationController
  skip_before_filter :authenticate_user!

  def new
    @usernames_reminder = UsernamesReminder.new
  end

  def create
    @usernames_reminder = UsernamesReminder.new(params[:usernames_reminder])

    if @usernames_reminder.valid?
      @usernames_reminder.send_email
      redirect_to new_user_session_path, notice: t('manage_users.usernames_reminder_sent')
    else
      render :new
    end
  end
end
