module LoanAlerts
  class Entry

    def initialize(loans, max_loan_count)
      @loans          = loans || []
      @max_loan_count = max_loan_count
    end

    def height
      return "0" if count.zero?
      ((count.to_f / @max_loan_count.to_f) * 100).to_i
    end

    def count
      @count ||= @loans.empty? ? 0 : @loans.size
    end

  end
end
