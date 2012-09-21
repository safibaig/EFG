class EligibilityDecisionEmail

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :email, :loan

  validates_presence_of :email, :loan
  validates_format_of :email, with: Devise.email_regexp

  def initialize(loan, params = {})
    @loan = loan
    @email = params[:email]
  end

  def deliver_email
    if loan.state == Loan::Eligible
      LoanEligibilityDecisionMailer.loan_eligible_email(email, loan).deliver
    elsif loan.state == Loan::Rejected
      LoanEligibilityDecisionMailer.loan_ineligible_email(email, loan).deliver
    end
  end

  def persisted?
    false
  end

end
