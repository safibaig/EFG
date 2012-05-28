class MonthDuration
  include Comparable

  def self.from_years_and_months(years, months)
    new((years * 12) + months)
  end

  def initialize(total_months)
    @total_months = total_months
    @years = @total_months / 12
    @months = @total_months % 12
  end

  attr_reader :years, :months, :total_months

  def <=>(other)
    other.total_months <=> total_months
  end

  def format
    out = []
    out << "#{years} year".pluralize(years) unless years.zero?
    out << "#{months} month".pluralize(months) unless months.zero?
    out.join(', ')
  end
end
