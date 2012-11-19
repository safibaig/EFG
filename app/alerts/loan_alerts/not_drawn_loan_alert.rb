# "Offered loans have 6 months to progress from offered to guaranteed state
# – if not they progress to auto cancelled""
class LoanAlerts::NotDrawnLoanAlert < LoanAlerts::LoanAlert
  def loans
    super.offered.facility_letter_date_between(alert_range.first, alert_range.last)
  end

  # Lenders have an extra 10 days of grace to record the initial draw.
  def self.start_date
    (6.months.ago - 10.days).to_date
  end

  def self.date_method
    :facility_letter_date
  end
end
