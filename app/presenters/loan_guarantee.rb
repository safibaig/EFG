class LoanGuarantee
  include LoanPresenter
  include LoanStateTransition

  transition from: Loan::Offered, to: Loan::Guaranteed

  attribute :received_declaration
  attribute :signed_direct_debit_received
  attribute :first_pp_received
  attribute :initial_draw_date
  attribute :initial_draw_value
  attribute :maturity_date

  validates_presence_of :initial_draw_date, :initial_draw_value, :maturity_date

  validate do
    errors.add(:received_declaration, :accepted) unless self.received_declaration
    errors.add(:signed_direct_debit_received, :accepted) unless self.signed_direct_debit_received
    errors.add(:first_pp_received, :accepted) unless self.first_pp_received
  end

  def initial_draw_date=(value)
    loan.initial_draw_date = QuickDateFormatter.parse(value)
  end

  def maturity_date=(value)
    loan.maturity_date = QuickDateFormatter.parse(value)
  end
end
