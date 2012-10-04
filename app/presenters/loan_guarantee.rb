class LoanGuarantee
  include LoanPresenter
  include LoanStateTransition

  transition from: Loan::Offered, to: Loan::Guaranteed, event: :guarantee_and_initial_draw

  after_save :create_initial_draw_change!

  attribute :received_declaration
  attribute :signed_direct_debit_received
  attribute :first_pp_received
  attribute :maturity_date

  attr_reader :initial_draw_amount, :initial_draw_date
  attr_accessible :initial_draw_amount, :initial_draw_date

  validates_presence_of :initial_draw_date, :initial_draw_amount, :maturity_date

  validate :initial_draw_is_not_greater_than_loan_amount

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
    def create_initial_draw_change!
      InitialDrawChange.create! do |initial_draw_change|
        initial_draw_change.amount_drawn = initial_draw_amount
        initial_draw_change.created_by = modified_by
        initial_draw_change.date_of_change = initial_draw_date
        initial_draw_change.loan = loan
        initial_draw_change.modified_date = Date.current
      end
    end

    def initial_draw_is_not_greater_than_loan_amount
      return if initial_draw_amount.blank?
      errors.add(:initial_draw_amount, :greater_than_loan_amount) if initial_draw_amount > loan.amount
    end
end
