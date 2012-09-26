class AskForHelpMailer < ActionMailer::Base
  default from: Devise.mailer_sender

  def ask_an_expert_email(ask_an_expert)
    @ask_an_expert = ask_an_expert

    mail(
      to: ask_an_expert.to,
      reply_to: ask_an_expert.from,
      subject: '[EFG] New support request from EFG'
    )
  end

  def ask_cfe_email(ask_cfe)
    @ask_cfe = ask_cfe

    mail(
      to: ask_cfe.to,
      reply_to: ask_cfe.from,
      subject: '[EFG] New support request from EFG'
    )
  end
end
