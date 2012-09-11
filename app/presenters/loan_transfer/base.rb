class LoanTransfer::Base
  include LoanPresenter

  ALLOWED_LOAN_TRANSFER_STATES = [Loan::Guaranteed, Loan::Demanded, Loan::Repaid]

  attr_reader :loan_to_transfer, :new_loan

  attr_accessor :new_amount, :lender

  attribute :amount
  attribute :reference
  attribute :declaration_signed

  attr_accessible :new_amount

  validates_presence_of :amount, :new_amount, :reference, :lender

  validate do
    errors.add(:declaration_signed, :accepted) unless self.declaration_signed
  end

  def new_amount=(value)
    @new_amount = value.present? ? Money.parse(value) : nil
  end

  def loan_to_transfer
    raise NotImplementedError, "Define in sub-class"
  end

  def save
    return false unless valid? && loan_can_be_transferred?

    Loan.transaction do
      loan_to_transfer.modified_by = modified_by
      loan_to_transfer.state = Loan::RepaidFromTransfer
      loan_to_transfer.save!

      @new_loan                       = loan_to_transfer.dup
      new_loan.lender                = self.lender
      new_loan.amount                = self.new_amount
      new_loan.reference             = reference_class.new(loan_to_transfer.reference).increment
      new_loan.state                 = Loan::Incomplete
      new_loan.legacy_id             = nil
      new_loan.sortcode              = ''
      new_loan.repayment_duration    = 0
      new_loan.payment_period        = ''
      new_loan.maturity_date         = ''
      new_loan.invoice_id            = ''
      new_loan.transferred_from_id   = loan_to_transfer.id
      new_loan.lending_limit         = lender.lending_limits.active.first
      new_loan.created_by            = modified_by
      new_loan.modified_by           = modified_by
      # TODO - copy loan securities if any are present

      (1..5).each do |num|
        new_loan.send("generic#{num}=", nil)
      end

      yield new_loan if block_given?

      new_loan.save!
      log_loan_state_changes!
      create_initial_draw_change!
    end

    true
  end

  private

  def create_initial_draw_change!
    InitialDrawChange.create! do |initial_draw_change|
      initial_draw_change.amount_drawn = loan_to_transfer.cumulative_drawn_amount
      initial_draw_change.created_by = modified_by
      initial_draw_change.date_of_change = loan_to_transfer.initial_draw_change.date_of_change
      initial_draw_change.loan = new_loan
      initial_draw_change.modified_date = Date.current
    end
  end

  def loan_can_be_transferred?
    unless loan_to_transfer.is_a?(Loan)
      errors.add(:base, :cannot_be_transferred)
      return false
    end

    if loan_to_transfer.efg_loan?
       errors.add(:base, :cannot_be_transferred)
     end

    if new_amount > loan_to_transfer.amount
      errors.add(:new_amount, :cannot_be_greater)
    end

    unless ALLOWED_LOAN_TRANSFER_STATES.include?(loan_to_transfer.state)
      errors.add(:base, :cannot_be_transferred)
    end

    if loan_to_transfer.already_transferred?
      errors.add(:base, :cannot_be_transferred)
    end

    if loan_to_transfer.lender == lender
      errors.add(:base, :cannot_transfer_own_loan)
    end

    errors.empty?
  end

  def reference_class
    raise NotImplementedError, "Define in sub-class"
  end

  def loan_event_id
    raise NotImplementedError, "Define in sub-class"
  end

  def log_loan_state_changes!
    [loan_to_transfer, new_loan].each do |loan|
      loan.state_changes.create!(
        state: loan.state,
        modified_on: Date.today,
        modified_by: loan.modified_by,
        event_id: loan_event_id
      )
    end
  end

end
