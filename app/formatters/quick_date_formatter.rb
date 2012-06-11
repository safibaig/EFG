module QuickDateFormatter
  def self.format(value)
    value
  end

  def self.parse(value)
    case value
    when nil
      nil
    when Date, Time
      value.to_date
    else
      match = value.to_s.match(%r{(\d+)/(\d+)/(\d+)})
      return unless match
      day, month, year = match[1..3].map(&:to_i)
      year += 2000 if year < 2000
      Date.new(year, month, day)
    end
  end
end
