class LoanAlerts::NotClosedLoanAlert < LoanAlerts::LoanAlert
  def initialize(lender, priority = nil)
    super

    @guaranteed = LoanAlerts::NotClosedGuaranteedLoanAlert.new(lender, priority)
    @offered = LoanAlerts::NotClosedOfferedLoanAlert.new(lender, priority)
  end

  def self.date_method
    :maturity_date
  end

  def loans
    [@guaranteed, @offered].map(&:loans).flatten(1).sort_by(&date_method)
  end

  def start_date
    @offered.start_date
  end
end
