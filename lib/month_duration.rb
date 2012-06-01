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
    total_months <=> other.total_months
  end

  def format
    out = []
    out << pluralize(years, "year") unless years.zero?
    out << pluralize(months, "month") unless months.zero?
    out.join(', ')
  end
end
