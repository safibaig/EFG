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
    total_months <=> other.total_months
  end

  def format
    out = []
    if not years.zero?
      out << if years > 1
        "#{years} years"
      else
        "1 year"
      end
    end

    if not months.zero?
      out << if months > 1
        "#{months} months"
      else
        "1 month"
      end
    end
    out.join(', ')
  end
end
