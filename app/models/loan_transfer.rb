class LoanTransfer
  include FormatterConcern

  extend  ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::MassAssignmentSecurity
  include ActiveModel::Validations

  ALLOWED_LOAN_TRANSFER_STATES = [Loan::Guaranteed, Loan::Demanded, Loan::Repaid]

  attr_accessor :amount, :new_amount, :reference,
                :facility_letter_date, :declaration_signed

  attr_accessible :amount, :new_amount, :reference, :facility_letter_date, :declaration_signed

  validates_presence_of :amount
  validates_presence_of :new_amount
  validates_presence_of :reference
  validates_presence_of :facility_letter_date
  validates_acceptance_of :declaration_signed, accept: 'true' , allow_nil: false

  def initialize(attrs = {})
    self.attributes = attrs
  end

  def attributes=(attributes)
    sanitize_for_mass_assignment(attributes).each do |k, v|
      public_send("#{k}=", v)
    end
  end

  def valid_loan_transfer_request?
    valid? && valid_loan_transfer?
  end

  # TODO - use formatters for money and dates

  def amount=(value)
    @amount = value.present? ? Money.parse(value) : nil
  end

  def new_amount=(value)
    @new_amount = value.present? ? Money.parse(value) : nil
  end

  def facility_letter_date=(date_string)
    @facility_letter_date = date_string.present? ? Date.parse(date_string) : nil
  end

  def persisted?
    false
  end

  def loan_to_transfer
    @loan_to_transfer ||= Loan.where(
      reference: reference,
      amount: amount.cents,
      facility_letter_date: facility_letter_date.to_s(:db)
    ).first
  end

  private

  # TODO - get correct text for these validation errors
  # TODO - move error text to I18n YAML
  def valid_loan_transfer?
    unless loan_to_transfer.is_a?(Loan)
      errors.add(:base, 'Could not find the specified loan, please check the data you have entered')
      return false
    end

    if new_amount > loan_to_transfer.amount
      errors.add(:new_amount, 'cannot be greater than the amount of the loan being transferred')
    end

    unless ALLOWED_LOAN_TRANSFER_STATES.include?(loan_to_transfer.state)
      errors.add(:base, 'The specified loan cannot be transferred')
    end

    if loan_to_transfer.transferred?
      errors.add(:base, 'The specified loan cannot be transferred')
    end

    errors.empty?
  end

end
