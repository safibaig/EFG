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

  private

  def reference_class
    LegacyLoanReference
  end

end
