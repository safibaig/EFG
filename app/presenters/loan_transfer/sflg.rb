class LoanTransfer::Sflg < LoanTransfer::Base

  attribute :facility_letter_date

  validates_presence_of :facility_letter_date

  def loan_to_transfer
    @loan_to_transfer ||= Loan.where(
      reference: reference,
      amount: amount.cents,
      facility_letter_date: facility_letter_date,
      state: ALLOWED_LOAN_TRANSFER_STATES
    ).first
  end

  private

  def reference_class
    LoanReference
  end

  def loan_event_id
    LoanEvent.find(15).id # Transfer
  end

end
