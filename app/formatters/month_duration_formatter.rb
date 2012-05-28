require 'month_duration'

module MonthDurationFormatter
  def self.format(months)
    MonthDuration.new(months) if months
  end

  def self.parse(hash)
    return if hash.blank? || hash.all? {|_, value| value.blank? }

    years = hash.fetch(:years, 0).to_i
    months = hash.fetch(:months, 0).to_i
    MonthDuration.from_years_and_months(years, months).total_months
  end
end
