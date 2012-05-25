require 'active_model/model'

class LoanGuarantee
  include ActiveModel::Model

  READ_ONLY_ATTRIBUTES = [:initial_draw_date, :maturity_date]

  delegate *READ_ONLY_ATTRIBUTES, to: :loan

  ATTRIBUTES = [:received_declaration, :signed_direct_debit_received,
                :first_pp_received, :initial_draw_date, :initial_draw_value]

  ATTRIBUTES.each do |attribute|
    delegate attribute, "#{attribute}=", to: :loan
  end
  delegate :errors, :save, to: :loan

  attr_reader :loan

  def initialize(loan, attributes = {})
    @loan = loan
    super(attributes)
  end

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
