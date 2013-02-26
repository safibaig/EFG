require 'active_model/model'

class UsernamesReminder
  include ActiveModel::Model

  attr_accessor :email

  validates :email, presence: true, email: true

  def send_email
    if usernames_for_email.present?
      UsernamesReminderMailer.usernames_reminder(email, usernames_for_email).deliver
    end
  end

  private
  def usernames_for_email
    User.where(email: email).pluck(:username)
  end
end
