require 'active_model/model'

class LoanOffer
  include ActiveModel::Model

  READ_ONLY_ATTRIBUTES = [:facility_letter_date]

  delegate *READ_ONLY_ATTRIBUTES, to: :loan

  ATTRIBUTES = [:facility_letter_sent]

  ATTRIBUTES.each do |attribute|
    delegate attribute, "#{attribute}=", to: :loan
  end
  delegate :errors, :save, to: :loan

  attr_reader :loan

  def initialize(loan, attributes = {})
    @loan = loan
    super(attributes)
  end

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
