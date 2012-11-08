# "Legacy or new scheme guaranteed loans – if maturity date has elapsed by 6 months – auto remove
class LoanAlerts::NotClosedOfferedLoanAlert < LoanAlerts::LoanAlert
  def loans
    lender.loans.
      with_scheme('non_efg').
      guaranteed.
      maturity_date_between(alert_range.first, alert_range.end).
      order(:maturity_date)
  end

  def self.start_date
    6.months.ago.to_date
  end
end
