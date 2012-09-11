class LoanTransfer::LegacySflg < LoanTransfer::Base

  attr_accessor :legacy_loan
  attr_reader :initial_draw_date
  attr_accessible :initial_draw_date

  validates_presence_of :initial_draw_date

  def initial_draw_date=(value)
    @initial_draw_date = value.present? ? QuickDateFormatter.parse(value) : nil
  end

  def loan_to_transfer
    @loan_to_transfer ||= Loan.joins(:initial_draw_change).where(
      amount: amount.cents,
      loan_modifications: { date_of_change: initial_draw_date },
      reference: reference,
      state: ALLOWED_LOAN_TRANSFER_STATES
    ).first(readonly: false)
  end

  def save
    super do |new_loan|
      new_loan.declaration_signed = true
      new_loan.viable_proposition = true
      new_loan.collateral_exhausted = true
      new_loan.previous_borrowing = true
      new_loan.facility_letter_date = nil
      new_loan.would_you_lend = true
      new_loan.notified_aid = false
      new_loan.state_aid = nil
      new_loan.state_aid_is_valid = true
    end
  end

  private

  def reference_class
    LegacyLoanReference
  end

  def loan_event_id
    23 # Transfer (legacy)
  end

end
