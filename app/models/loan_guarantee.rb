class LoanGuarantee
  include LoanStateTransition

  attribute :received_declaration
  attribute :signed_direct_debit_received
  attribute :first_pp_received
  attribute :initial_draw_date
  attribute :initial_draw_value
  attribute :maturity_date

  def initial_draw_date=(value)
    match = value.match(%r{(\d+)/(\d+)/(\d+)})
    return unless match
    day, month, year = match[1..3].map(&:to_i)
    year += 2000 if year < 2000
    loan.initial_draw_date = Date.new(year, month, day)
  end

  def maturity_date=(value)
    match = value.match(%r{(\d+)/(\d+)/(\d+)})
    return unless match
    day, month, year = match[1..3].map(&:to_i)
    year += 2000 if year < 2000
    loan.maturity_date = Date.new(year, month, day)
  end
end
