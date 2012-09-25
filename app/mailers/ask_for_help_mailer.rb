class AskForHelpMailer < ActionMailer::Base
  default from: Devise.mailer_sender

  def ask_cfe_email(ask_cfe)
    @ask_cfe = ask_cfe

    mail(
      to: ask_cfe.to,
      reply_to: ask_cfe.from,
      subject: '[EFG] New support request from EFG'
    )
  end
end
