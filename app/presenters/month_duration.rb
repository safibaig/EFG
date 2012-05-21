class MonthDuration
  include Comparable

  def self.from_params(hash)
    years = hash.fetch(:years, 0).to_i
    months = hash.fetch(:months, 0).to_i
    total_months = (years * 12) + months
    new(total_months)
  end

  def initialize(months)
    @total_months = months.to_i
    @years = @total_months / 12
    @months = @total_months % 12
  end

  attr_reader :years, :months, :total_months

  def <=>(other)
    other.total_months <=> total_months
  end
end
