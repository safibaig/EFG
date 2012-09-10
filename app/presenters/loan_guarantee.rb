class LoanGuarantee
  include LoanPresenter
  include LoanStateTransition

  transition from: Loan::Offered, to: Loan::Guaranteed, event: :guarantee_and_initial_draw

  after_save :create_initial_loan_change!

  attribute :received_declaration
  attribute :signed_direct_debit_received
  attribute :first_pp_received
  attribute :maturity_date

  attr_reader :initial_draw_amount, :initial_draw_date
  attr_accessible :initial_draw_amount, :initial_draw_date

  validates_presence_of :initial_draw_date, :initial_draw_amount, :maturity_date

  validate do
    errors.add(:received_declaration, :accepted) unless self.received_declaration
    errors.add(:signed_direct_debit_received, :accepted) unless self.signed_direct_debit_received
    errors.add(:first_pp_received, :accepted) unless self.first_pp_received
  end

  def initial_draw_amount=(value)
    @initial_draw_amount = value.present? ? Money.parse(value) : nil
  end

  def initial_draw_date=(value)
    @initial_draw_date = value.present? ? QuickDateFormatter.parse(value) : nil
  end

  private
    def create_initial_loan_change!
      initial_loan_change = loan.loan_changes.new
      initial_loan_change.amount_drawn = initial_draw_amount
      initial_loan_change.created_by = modified_by
      initial_loan_change.date_of_change = initial_draw_date
      initial_loan_change.modified_date = Date.current
      initial_loan_change.save!
    end
end
