# Loan Alert sub-classes & behaviour from 'CfEL Response to Initial Questions.docx'.
#
# Note: alert range is 60 week days (no support for public holidays)
class LoanAlerts::LoanAlert
  def initialize(lender, priority = nil)
    @lender = lender
    @priority = priority
  end

  attr_reader :lender, :priority

  def loans
    lender.loans.order(self.class.date_method)
  end

  def self.start_date
    raise NotImplementedError, 'subclasses must implement .start_date'
  end

  def self.end_date
    59.weekdays_from(start_date).to_date
  end

  def self.date_method
    raise NotImplementedError, 'subclasses must implement .date_method'
  end

  def alert_range
    @alert_range ||= begin
      high_priority_start_date   = self.class.start_date
      medium_priority_start_date = 9.weekdays_from(high_priority_start_date).advance(days: 1)
      low_priority_start_date    = 19.weekdays_from(medium_priority_start_date).advance(days: 1)
      default_end_date           = self.class.end_date

      start_date = {
        "high"   => high_priority_start_date,
        "medium" => medium_priority_start_date,
        "low"    => low_priority_start_date
      }.fetch(priority, high_priority_start_date)

      end_date = {
        "high"   => 9.weekdays_from(high_priority_start_date),
        "medium" => 19.weekdays_from(medium_priority_start_date),
        "low"    => 29.weekdays_from(low_priority_start_date)
      }.fetch(priority, default_end_date)

      (start_date..end_date)
    end
  end
end
