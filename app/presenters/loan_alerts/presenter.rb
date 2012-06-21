module LoanAlerts
  class Presenter

    def initialize(priority_groups)
      @high_priority_loans   = priority_groups[:high_priority]
      @medium_priority_loans = priority_groups[:medium_priority]
      @low_priority_loans    = priority_groups[:low_priority]
    end

    def alerts_grouped_by_priority
      [
        Group.new(@high_priority_loans, :high, max_loan_count),
        Group.new(@medium_priority_loans, :medium, max_loan_count),
        Group.new(@low_priority_loans, :low, max_loan_count)
      ]
    end

    private

    def max_loan_count
      @max_loan_count ||= [
        @high_priority_loans.collect(&:length).max,
        @medium_priority_loans.collect(&:length).max,
        @low_priority_loans.collect(&:length).max
      ].max
    end

  end
end
