# Takes an array of loans and groups them by priority for use in a dashboard loan alert graph
#
#   high priority: loans within 10 week days of the start date
#   medium priority: loans between 11 and 30 week days of the start date
#   low priority: loans between 31 and 60 week days of the start date
#
module LoanAlerts
  class PriorityGrouping

    def initialize(loans, start_date, end_date, date_method)
      @loans       = loans
      @start_date  = start_date.to_date
      @end_date    = end_date.to_date
      @date_method = date_method
    end

    # Merge two PriorityGroup hashes together
    # Used when a loan alert consists of more than one grouping of records
    def self.merge_groups(group1, group2)
      group1.keys.each do |key|

        group1[key].each_with_index do |sub_array, index|
          group2[key].fetch(index, [])
          group1[key][index] = sub_array + group2[key].fetch(index, [])
        end

      end

      group1
    end

    def groups_hash
      { high_priority: high_priority_loans, medium_priority: medium_priority_loans, low_priority: low_priority_loans }
    end

    private

    def loans_grouped_by_date_condition
      loans_by_day.collect do |array|
        array[1] if yield array[0]
      end.compact
    end

    def days_range
      @days_range ||= (@start_date..@end_date).select { |date| date.weekday? }
    end

    def loans_grouped_by_day
      @loans_grouped_by_day ||= @loans.inject({}) do |memo, loan|
        date = loan.send(@date_method)
        # shift weekend dates to weekdays
        date = (date + 1.day) until date.weekday?
        date = date.to_date

        memo[date] ||= []
        memo[date] << loan
        memo
      end
    end

    def loans_by_day
      @loans_by_day ||= days_range.inject({}) do |memo, date|
        return memo unless date.weekday? # ignore weekends
        memo[date] = loans_grouped_by_day[date] || []
        memo
      end
    end

    def high_priority_loans
      loans_grouped_by_date_condition do |date|
        date <= high_priority_end_date
      end
    end

    def medium_priority_loans
      loans_grouped_by_date_condition do |date|
        date.between?(medium_priority_start_date, medium_priority_end_date)
      end
    end

    def low_priority_loans
      loans_grouped_by_date_condition do |date|
        date >= medium_priority_end_date.advance(days: 1)
      end
    end

    def medium_priority_start_date
      high_priority_end_date.advance(days: 1).to_date
    end

    def medium_priority_end_date
      @medium_priority_end_date ||= 19.weekdays_from(medium_priority_start_date).to_date
    end

    def high_priority_end_date
      @high_priority_end_date ||= 9.weekdays_from(@start_date).to_date
    end

  end
end
