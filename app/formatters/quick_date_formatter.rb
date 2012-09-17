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
      match = value.to_s.match(%r{^(\d{,2})/(\d{,2})/(\d{,4})$})
      return unless match
      day, month, year = match[1..3]
      year = "20#{year}" if year.length == 2
      Date.new(year.to_i, month.to_i, day.to_i)
    end
  end
end
