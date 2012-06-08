module QuickDateFormatter
  def self.parse(value)
    match = value.to_s.match(%r{(\d+)/(\d+)/(\d+)})
    return unless match
    day, month, year = match[1..3].map(&:to_i)
    year += 2000 if year < 2000
    Date.new(year, month, day)
  end
end
