class SupportRequestMailer < ActionMailer::Base

  default :from => Devise.mailer_sender

  def notification_email(support_request, browser, operating_system)
    @support_request = support_request
    @browser = browser
    @operating_system = operating_system

    mail(
      to: @support_request.recipients,
      reply_to: @support_request.user.email,
      subject: "[EFG] New support request from EFG"
    )
  end

end
