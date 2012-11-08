class LoanAlerts::SFLGNotClosedLoanAlert < LoanAlerts::LoanAlert
  def self.start_date
    6.months.ago.to_date
  end
end
