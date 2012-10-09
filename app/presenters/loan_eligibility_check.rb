class LoanEligibilityCheck
  include LoanPresenter
  include LoanStateTransition
  include SharedLoanValidations

  MAX_ALLOWED_TURNOVER = Money.new(41_000_000_00)

  attribute :viable_proposition
  attribute :would_you_lend
  attribute :collateral_exhausted
  attribute :lender
  attribute :lending_limit_id, readonly: true
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

  validates_presence_of :amount, :lending_limit_id, :repayment_duration,
    :turnover, :trading_date, :sic_code, :loan_category_id, :reason_id
  validates_inclusion_of :viable_proposition, :would_you_lend,
    :collateral_exhausted, :previous_borrowing,
    :private_residence_charge_required, :personal_guarantee_required, in: [true, false]
  validates_inclusion_of :loan_scheme, in: [ Loan::EFG_SCHEME ]
  validates_inclusion_of :loan_source, in: [ Loan::SFLG_SOURCE ]
  validates_numericality_of :turnover, less_than_or_equal_to: MAX_ALLOWED_TURNOVER.to_f

  validate :repayment_duration_within_loan_category_limits, if: :repayment_duration

  validate :trading_date_within_next_six_months, if: :trading_date

  validate do
    errors.add(:amount, :greater_than, count: 0) unless amount && amount.cents > 0
    errors.add(:sic_code, :not_recognised) if sic_code.blank?
  end

  after_save :save_ineligibility_reasons, unless: :is_eligible?

  def transition_to
    is_eligible? ? Loan::Eligible : Loan::Rejected
  end

  def event
    is_eligible? ? LoanEvent.find_by_name("Accept") : LoanEvent.find_by_name("Reject")
  end

  def lending_limit_id=(id)
    if id.present?
      lending_limit = loan.lender.lending_limits.active.find(id)
      loan.lending_limit = lending_limit
    else
      loan.lending_limit = nil
    end

    loan.lending_limit_id
  end

  # cache sic code data on loan, as per legacy system
  def sic_code=(code)
    loan.sic_code = loan.sic_desc = loan.sic_eligible = nil
    if sic_code = SicCode.find_by_code(code)
      loan.sic_code = sic_code.code
      loan.sic_desc = sic_code.description
      loan.sic_eligible = sic_code.eligible
    end
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

  def trading_date_within_next_six_months
    errors.add(:trading_date, :too_far_in_the_future) if trading_date > Date.today.advance(months: 6)
  end

end
