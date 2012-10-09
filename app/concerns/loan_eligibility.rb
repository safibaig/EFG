module LoanEligibility
  extend ActiveSupport::Concern

  def eligibility_check
    @eligibility_check ||= EligibilityCheck.new(loan)
  end

  def is_eligible?
    eligibility_check.eligible?
  end

  def save_ineligibility_reasons
    loan.ineligibility_reasons.create!(reason: eligibility_check.reasons.join("\n"))
  end

end
