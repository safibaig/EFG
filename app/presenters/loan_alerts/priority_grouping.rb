# Takes an array of loans and groups them by priority for use in a dashboard loan alert graph
#
#   high priority: loans within 10 days of the start date
#   medium priority: loans between 11 and 30 days of the start date
#   low priority: loans between 31 and 60 days of the start date
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
          group2[key].fetch(index)
          group1[key][index] = sub_array + group2[key].fetch(index)
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
      @days_range ||= (@start_date.to_date..@end_date.to_date)
    end

    def loans_grouped_by_day
      @loans_grouped_by_day ||= @loans.group_by { |l| l.send(@date_method).to_date }
    end

    def loans_by_day
      @loans_by_day ||= days_range.inject({}) do |memo, date|
        memo[date] = loans_grouped_by_day[date] || []
        memo
      end
    end

    def high_priority_loans
      loans_grouped_by_date_condition do |date|
        date <= @start_date.advance(days: 9)
      end
    end

    def medium_priority_loans
      loans_grouped_by_date_condition do |date|
        date >= @start_date.advance(days: 10) && date <= @start_date.advance(days: 29)
      end
    end

    def low_priority_loans
      loans_grouped_by_date_condition do |date|
        date >= @start_date.advance(days: 30)
      end
    end

  end
end
