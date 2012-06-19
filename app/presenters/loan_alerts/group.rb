module LoanAlerts
  class Group

    attr_reader :priority

    def initialize(loans_by_day, priority, max_loan_count)
      @loans_by_day   = loans_by_day
      @priority       = priority
      @max_loan_count = max_loan_count
    end

    def each_alert_by_day
      @loans_by_day.each do |loans|
        yield Entry.new(loans, @max_loan_count)
      end
    end

    def class_name
      "#{@priority}-priority"
    end

    def total_loans
      @loans_by_day.sum(&:length)
    end

  end
end
