class LoanGuarantee
  include LoanPresenter

  attribute :received_declaration
  attribute :signed_direct_debit_received
  attribute :first_pp_received
  attribute :initial_draw_date
  attribute :initial_draw_value
  attribute :maturity_date

  def initial_draw_date=(value)
    loan.initial_draw_date = QuickDateFormatter.parse(value)
  end

  def maturity_date=(value)
    loan.maturity_date = QuickDateFormatter.parse(value)
  end
end
