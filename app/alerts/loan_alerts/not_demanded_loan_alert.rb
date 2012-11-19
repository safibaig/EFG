# "All new scheme and legacy loans that are in a state of “Lender Demand”
# have a 12 month time frame to be progressed to “Demanded”
# – if they do not, they will become “Auto Removed”."
# "EFG loans however, should not be subjected to this alert
class LoanAlerts::NotDemandedLoanAlert < LoanAlerts::LoanAlert
  def loans
    super.with_scheme('non_efg').lender_demanded.borrower_demanded_date_between(alert_range.first, alert_range.last)
  end

  def self.start_date
    365.days.ago.to_date
  end

  def self.date_method
    :borrower_demanded_on
  end
end
