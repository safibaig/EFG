class SupportRequestMailer < ActionMailer::Base

  default :from => Devise.mailer_sender

  # TODO: remove BCC from email prior to go live
  def notification_email(support_request, browser, operating_system)
    @support_request = support_request
    @browser = browser
    @operating_system = operating_system

    mail(
      to: @support_request.recipients,
      reply_to: @support_request.user.email,
      subject: "[EFG] New support request from EFG",
      bcc: CfeUser.with_email.collect(&:email) + %w(efg-support@digital.cabinet-office.gov.uk)
    )
  end

end
