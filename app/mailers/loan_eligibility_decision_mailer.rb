class LoanEligibilityDecisionMailer < ActionMailer::Base

  default :from => Devise.mailer_sender

  def loan_eligible_email(recipient_email, loan)
    @loan = loan

    mail(
      to: recipient_email,
      subject: "EFG/SFLG portal eligibility check - eligible"
    )
  end

  def loan_ineligible_email(recipient_email, loan)
    @loan = loan

    mail(
      to: recipient_email,
      subject: "EFG/SFLG portal eligibility check - rejected"
    )
  end

end