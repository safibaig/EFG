# Alert descriptions from 'CfEL Response to Initial Questions.docx'
#
# Note: alert range is 60 week days (no support for public holidays)
module LoanAlerts

  # "All schemes, any loan that has remained at the state of
  # “eligible” / “incomplete” or “complete”
  # – for a period of 6 months from entering those states – should be ‘auto cancelled’"
  def not_progressed_loans(priority = nil)
    NotProgressedLoanAlert.new(current_lender, priority).loans
  end

  def not_progressed_start_date
    NotProgressedLoanAlert.start_date
  end

  def not_progressed_end_date
    NotProgressedLoanAlert.end_date
  end

  # "Offered loans have 6 months to progress from offered to guaranteed state
  # – if not they progress to auto cancelled""
  def not_drawn_loans(priority = nil)
    NotDrawnLoanAlert.new(current_lender, priority).loans
  end

  def not_drawn_start_date
    NotDrawnLoanAlert.start_date
  end

  def not_drawn_end_date
    NotDrawnLoanAlert.end_date
  end

  # "All new scheme and legacy loans that are in a state of “Lender Demand”
  # have a 12 month time frame to be progressed to “Demanded”
  # – if they do not, they will become “Auto Removed”."
  # "EFG loans however, should not be subjected to this alert
  def not_demanded_loans(priority = nil)
    NotDemandedLoanAlert.new(current_lender, priority).loans
  end

  def not_demanded_start_date
    NotDemandedLoanAlert.start_date
  end

  def not_demanded_end_date
    NotDemandedLoanAlert.end_date
  end

  # "Legacy or new scheme guaranteed loans – if maturity date has elapsed by 6 months – auto remove
  def not_closed_offered_loans(priority = nil)
    NotClosedOfferedLoanAlert.new(current_lender, priority).loans
  end

  def not_closed_offered_start_date
    NotClosedOfferedLoanAlert.start_date
  end

  def not_closed_offered_end_date
    NotClosedOfferedLoanAlert.end_date
  end

  # EFG – if state ‘guaranteed’ and maturity date elapsed by 3 months – auto remove
  def not_closed_guaranteed_loans(priority = nil)
    NotClosedGuaranteedLoanAlert.new(current_lender, priority).loans
  end

  def not_closed_guaranteed_start_date
    NotClosedGuaranteedLoanAlert.start_date
  end

  def not_closed_guaranteed_end_date
    NotClosedGuaranteedLoanAlert.end_date
  end

  def sflg_not_closed_start_date
    SFLGNotClosedLoanAlert.start_date
  end

  def sflg_not_closed_end_date
    SFLGNotClosedLoanAlert.end_date
  end

  private

  def loans_for_alert(alert_name, priority = nil)
    high_priority_start_date   = send("#{alert_name}_start_date")
    medium_priority_start_date = 9.weekdays_from(high_priority_start_date).advance(days: 1)
    low_priority_start_date    = 19.weekdays_from(medium_priority_start_date).advance(days: 1)
    default_end_date           = send("#{alert_name}_end_date")

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

    yield current_lender.loans, start_date, end_date
  end

  private

  class LoanAlert
    def initialize(lender, priority = nil)
      @lender = lender
      @priority = priority
    end

    attr_reader :lender, :priority

    def loans
      raise NotImplementedError, 'subclasses must implement #loans'
    end

    def self.start_date
      raise NotImplementedError, 'subclasses must implement #start_date'
    end

    def self.end_date
      raise NotImplementedError, 'subclasses must implement #end_date'
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

  class NotProgressedLoanAlert < LoanAlert
    def loans
      lender.loans.not_progressed.last_updated_between(alert_range.first, alert_range.last).order(:updated_at)
    end

    def self.start_date
      6.months.ago.to_date
    end

    def self.end_date
      59.weekdays_from(start_date).to_date
    end
  end

  class NotDrawnLoanAlert < LoanAlert
    def loans
      lender.loans.offered.facility_letter_date_between(alert_range.first, alert_range.last).order(:facility_letter_date)
    end

    # Lenders have an extra 10 days of grace to record the initial draw.
    def self.start_date
      (6.months.ago - 10.days).to_date
    end

    def self.end_date
      59.weekdays_from(start_date).to_date
    end
  end

  class NotDemandedLoanAlert < LoanAlert
    def loans
      lender.loans.with_scheme('non_efg').lender_demanded.borrower_demanded_date_between(alert_range.first, alert_range.last).order(:borrower_demanded_on)
    end

    def self.start_date
      365.days.ago.to_date
    end

    def self.end_date
      59.weekdays_from(start_date).to_date
    end
  end

  class NotClosedOfferedLoanAlert < LoanAlert
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

    def self.end_date
      59.weekdays_from(start_date).to_date
    end
  end

  class NotClosedGuaranteedLoanAlert < LoanAlert
    def loans
      lender.loans.with_scheme('efg').guaranteed.maturity_date_between(alert_range.first, alert_range.end).order(:maturity_date)
    end

    def self.start_date
      3.months.ago.to_date
    end

    def self.end_date
      59.weekdays_from(start_date).to_date
    end
  end

  class SFLGNotClosedLoanAlert < LoanAlert
    def self.start_date
      6.months.ago.to_date
    end

    def self.end_date
      59.weekdays_from(start_date).to_date
    end
  end
end
