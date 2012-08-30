class LoanEligibilityCheck
  include LoanPresenter
  include LoanStateTransition

  attribute :viable_proposition
  attribute :would_you_lend
  attribute :collateral_exhausted
  attribute :lender
  attribute :loan_allocation_id
  attribute :sic_code
  attribute :loan_category_id
  attribute :reason_id
  attribute :previous_borrowing
  attribute :private_residence_charge_required
  attribute :personal_guarantee_required
  attribute :amount
  attribute :turnover
  attribute :repayment_duration
  attribute :trading_date
  attribute :loan_scheme
  attribute :loan_source

  delegate :created_by, :created_by=, to: :loan

  validates_presence_of :amount, :loan_allocation_id, :repayment_duration,
    :turnover, :trading_date, :sic_code, :loan_category_id, :reason_id
  validates_inclusion_of :viable_proposition, :would_you_lend,
    :collateral_exhausted, :previous_borrowing,
    :private_residence_charge_required, :personal_guarantee_required, in: [true, false]
  validates_inclusion_of :loan_scheme, in: [ Loan::EFG_SCHEME ]
  validates_inclusion_of :loan_source, in: [ Loan::SFLG_SOURCE ]

  validate do
    errors.add(:amount, :greater_than, count: 0) unless amount && amount.cents > 0
    errors.add(:repayment_duration, :greater_than, count: 0) unless repayment_duration && repayment_duration.total_months > 0
  end

  after_save :save_ineligibility_reasons, unless: :is_eligible?

  def transition_to
    is_eligible? ? Loan::Eligible : Loan::Rejected
  end

  def event
    is_eligible? ? LoanEvent.find_by_name("Accept") : LoanEvent.find_by_name("Reject")
  end

  private

  def eligibility_check
    @eligibility_check ||= EligibilityCheck.new(loan)
  end

  def is_eligible?
    eligibility_check.eligible?
  end

  def save_ineligibility_reasons
    loan.ineligibility_reasons.create!(reason: eligibility_check.reasons.join("\n"))
  end

end
