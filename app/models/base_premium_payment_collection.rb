class BasePremiumPaymentCollection
  include Enumerable

  def initialize(premium_schedule)
    @premium_schedule = premium_schedule
  end

  def each(&block)
    enumerator.each(&block)
  end

  def to_a
    enumerator.to_a
  end

  def [](index)
    premium_amount_for_quarter(LoanQuarter.new(index))
  end

  private

  attr_reader :premium_schedule

  def enumerator
    Enumerator.new do |yielder|
      range_of_quarters.each do |quarter|
        yielder.yield premium_amount_for_quarter(quarter)
      end
    end
  end

  def premium_amount_for_quarter(quarter)
    unless range_of_quarters.map(&:quarter_number).include?(quarter.quarter_number)
      raise ArgumentError, 'quarter out of bounds'
    end
  end

  def range_of_quarters
    (0...number_of_quarters).map { |n| LoanQuarter.new(n) }
  end

  def number_of_quarters
    @number_of_quarters ||= (premium_schedule.repayment_duration.to_f / 3).ceil
  end
end
