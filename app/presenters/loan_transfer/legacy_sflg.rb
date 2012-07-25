class LoanTransfer::LegacySflg < LoanTransfer::Base

  attr_accessor :legacy_loan

  attribute :initial_draw_date

  validates_presence_of :initial_draw_date

  def loan_to_transfer
    @loan_to_transfer ||= Loan.where(
      reference: reference,
      amount: amount.cents,
      initial_draw_date: initial_draw_date,
      state: ALLOWED_LOAN_TRANSFER_STATES
    ).first
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

end
