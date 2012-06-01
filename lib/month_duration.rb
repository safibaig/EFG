class MonthDuration
  include Comparable
  include ActionView::Helpers::TextHelper

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
    if not years.zero?
      out << pluralize(years, "year")
    end

    if not months.zero?
      out << pluralize(months, "month")
    end
    out.join(', ')
  end
end
