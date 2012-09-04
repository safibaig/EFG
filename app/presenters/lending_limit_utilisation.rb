class LendingLimitUtilisation

  attr_reader :lending_limit

  def initialize(lending_limit)
    @lending_limit = lending_limit
  end

  delegate :name, to: :lending_limit
  delegate :allocation, to: :lending_limit

  def chart_colour
    if usage_percentage.to_f > 85.0
      "#ff0000"
    elsif usage_percentage.to_f > 50.0
      "#FF7E00"
    else
      "#00c000"
    end
  end

  def usage_amount
    @usage_amount ||= Money.new(lending_limit.loans_using_lending_limit.sum(:amount))
  end

  def usage_percentage
    return 0 if usage_amount.zero?

    percentage = (usage_amount / allocation) * 100
    sprintf("%03.2f", percentage)
  end

end
