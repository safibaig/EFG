class LoanOffer
  include LoanStateTransition

  attribute :facility_letter_date
  attribute :facility_letter_sent

  def facility_letter_date=(value)
    match = value.match(%r{(\d+)/(\d+)/(\d+)})
    return unless match
    day, month, year = match[1..3].map(&:to_i)
    year += 2000 if year < 2000
    loan.facility_letter_date = Date.new(year, month, day)
  end

  def lending_limit_details
    loan.lender_cap.name
  end
end
