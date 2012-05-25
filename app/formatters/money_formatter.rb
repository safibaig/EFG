module MoneyFormatter
  def self.format(value)
    Money.new(value) if value
  end

  def self.parse(value)
    Money.parse(value).cents if value.present?
  end
end
