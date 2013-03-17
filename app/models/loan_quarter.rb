class LoanQuarter
  attr_reader :quarter_number

  def initialize(quarter_number)
    @quarter_number = quarter_number
  end

  def last_month
    3 * @quarter_number
  end
end
