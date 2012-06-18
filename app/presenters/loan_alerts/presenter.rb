module LoanAlerts
  class Presenter

    def initialize(loans, start_date, end_date)
      @loans      = loans
      @start_date = start_date.to_date
      @end_date   = end_date.to_date
    end

    def alerts_grouped_by_priority
      [
        Group.new(high_priority_loans, :high, max_loan_count),
        Group.new(medium_priority_loans, :medium, max_loan_count),
        Group.new(low_priority_loans, :low, max_loan_count)
      ]
    end

    private

    def days_range
      @days_range ||= (@start_date.to_date..@end_date.to_date)
    end

    def loans_grouped_by_day
      @loans_grouped_by_day ||= @loans.group_by { |l| l.updated_at.to_date }
    end

    def loans_by_day
      @loans_by_day ||= days_range.inject({}) do |memo, date|
        loans_for_day = loans_grouped_by_day[date] || []
        memo[date] = loans_for_day
        memo
      end
    end

    def loans_grouped_by_date_condition
      loans_by_day.collect do |array|
        array[1] if yield array[0]
      end.compact
    end

    def max_loan_count
      @max_loan_count ||= loans_grouped_by_day.map { |array| array[1].length }.max
    end

    def high_priority_loans
      loans_grouped_by_date_condition do |date|
        date <= @start_date + 9.days
      end
    end

    def medium_priority_loans
      loans_grouped_by_date_condition do |date|
        date > @start_date + 10.days && date <= @start_date + 30.days
      end
    end

    def low_priority_loans
      loans_grouped_by_date_condition do |date|
        date > @start_date + 31.days
      end
    end

  end
end