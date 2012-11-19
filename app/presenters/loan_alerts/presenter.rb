module LoanAlerts
  class Presenter

    def initialize(priority_group)
      @high_priority_loans   = priority_group.high_priority_loans
      @medium_priority_loans = priority_group.medium_priority_loans
      @low_priority_loans    = priority_group.low_priority_loans
    end

    def alerts_grouped_by_priority
      [
        Group.new(@high_priority_loans, :high, total_loan_count),
        Group.new(@medium_priority_loans, :medium, total_loan_count),
        Group.new(@low_priority_loans, :low, total_loan_count)
      ]
    end

    def total_loan_count
      @total_loan_count ||= [
        @high_priority_loans.collect(&:length).max,
        @medium_priority_loans.collect(&:length).max,
        @low_priority_loans.collect(&:length).max
      ].max
    end

  end
end
