class AskForHelpMailer < ActionMailer::Base
  default(
    from: Devise.mailer_sender,
    subject: '[EFG] New support request from EFG'
  )

  def ask_an_expert_email(ask_an_expert)
    @ask_an_expert = ask_an_expert

    mail(
      to: ask_an_expert.to,
      reply_to: ask_an_expert.from
    )
  end

  def ask_cfe_email(ask_cfe)
    @ask_cfe = ask_cfe

    mail(
      to: ask_cfe.to,
      reply_to: ask_cfe.from
    )
  end
end
