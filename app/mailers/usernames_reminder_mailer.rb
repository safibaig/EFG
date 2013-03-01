class UsernamesReminderMailer < ActionMailer::Base
  default :from => Devise.mailer_sender

  def usernames_reminder(email_address, usernames)
    @usernames = usernames
    mail(to: email_address, subject: 'EFG Username Reminder')
  end
end

