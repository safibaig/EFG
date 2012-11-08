# "All schemes, any loan that has remained at the state of
# “eligible” / “incomplete” or “complete”
# – for a period of 6 months from entering those states – should be ‘auto cancelled’"
class LoanAlerts::NotProgressedLoanAlert < LoanAlerts::LoanAlert
  def loans
    lender.loans.not_progressed.last_updated_between(alert_range.first, alert_range.last).order(:updated_at)
  end

  def self.start_date
    6.months.ago.to_date
  end

  def self.date_method
    :updated_at
  end
end
