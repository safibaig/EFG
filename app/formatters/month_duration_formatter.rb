require 'month_duration'

module MonthDurationFormatter
  def self.format(months)
    MonthDuration.new(months) if months
  end

  def self.parse(value)
    return if value.blank?
    return if value.is_a?(Hash) && value.all? {|_, v| v.blank? }
    return value if value.is_a?(Fixnum)

    years = value.fetch(:years, 0).to_i
    months = value.fetch(:months, 0).to_i
    MonthDuration.from_years_and_months(years, months).total_months
  end
end
