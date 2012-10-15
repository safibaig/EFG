class LoanEntry
  include LoanPresenter
  include LoanStateTransition
  include LoanEligibility
  include SharedLoanValidations

  transition from: [Loan::Eligible, Loan::Incomplete], to: Loan::Completed, event: :complete

  attribute :lender, read_only: true

  attribute :viable_proposition
  attribute :would_you_lend
  attribute :collateral_exhausted
  attribute :sic_code
  attribute :loan_category_id
  attribute :reason_id
  attribute :previous_borrowing
  attribute :private_residence_charge_required
  attribute :personal_guarantee_required
  attribute :amount
  attribute :turnover
  attribute :trading_date
  attribute :lending_limit_id
  attribute :repayment_duration
  attribute :declaration_signed
  attribute :business_name
  attribute :trading_name
  attribute :legal_form_id
  attribute :maturity_date
  attribute :company_registration
  attribute :postcode
  attribute :non_validated_postcode
  attribute :sortcode
  attribute :repayment_frequency_id
  attribute :generic1
  attribute :generic2
  attribute :generic3
  attribute :generic4
  attribute :generic5
  attribute :town
  attribute :interest_rate_type_id
  attribute :interest_rate
  attribute :fees
  attribute :state_aid_is_valid
  attribute :state_aid
  attribute :loan_security_types
  attribute :security_proportion
  attribute :original_overdraft_proportion
  attribute :refinance_security_proportion
  attribute :current_refinanced_amount
  attribute :final_refinanced_amount
  attribute :overdraft_limit
  attribute :overdraft_maintained
  attribute :invoice_discount_limit
  attribute :debtor_book_coverage
  attribute :debtor_book_topup

  after_save :save_as_ineligible, unless: :is_eligible?

  validates_presence_of :business_name, :legal_form_id, :interest_rate_type_id,
                        :repayment_frequency_id, :postcode, :maturity_date,
                        :interest_rate, :fees, :repayment_duration

  validates_presence_of :company_registration, if: :company_registration_required?

  validate :state_aid_calculated

  validate :repayment_frequency_allowed

  validate :maturity_date_within_loan_term, if: :maturity_date

  validate :company_turnover_is_allowed, if: :turnover

  validate do
    errors.add(:declaration_signed, :accepted) unless self.declaration_signed
  end

  # TYPE B LOANS

  validates_numericality_of :security_proportion,
                            greater_than: 0.0,
                            less_than: 100,
                            if: lambda { loan_category_id == 2 }

  validate :loan_security, if: lambda { loan_category_id == 2 }

  # TYPE C LOANS

  validates_numericality_of :original_overdraft_proportion,
                            greater_than: 0.0,
                            less_than: 100,
                            if: lambda { loan_category_id == 3 }

  # TYPE C & D LOANS

  validates_numericality_of :refinance_security_proportion,
                            greater_than: 0.0,
                            less_than_or_equal_to: 100,
                            if: lambda { [3,4].include?(loan_category_id) }

  # TYPE D LOANS

  validates_presence_of :current_refinanced_amount, :final_refinanced_amount,
                        if: lambda { loan_category_id == 4 }

  # TYPE E LOANS

  validates_presence_of :overdraft_limit,
                        if: lambda { loan_category_id == 5 }

  validates_inclusion_of :overdraft_maintained,
                         in: [true],
                         if: lambda { loan_category_id == 5 }

  # TYPE F LOANS

  validates_presence_of :invoice_discount_limit,
                        if: lambda { loan_category_id == 6 }

  validates_numericality_of :debtor_book_coverage,
                            greater_than_or_equal_to: 1,
                            less_than: 100,
                            if: lambda { loan_category_id == 6 }

  validates_numericality_of :debtor_book_topup,
                            greater_than_or_equal_to: 1,
                            less_than_or_equal_to: 30,
                            if: lambda { loan_category_id == 6 }

  def save_as_incomplete
    loan.state = Loan::Incomplete
    loan.save(validate: false)
  end

  private

  # Note: state aid must be recalculated if the loan term has changed
  def state_aid_calculated
    errors.add(:state_aid, :calculated) unless self.loan.state_aid_calculation
    errors.add(:state_aid, :recalculate) if self.loan.repayment_duration_changed?
  end

  # Type B loans require at least one security
  def loan_security
    errors.add(:loan_security_types, :present) if self.loan_security_types.empty?
  end

  def company_registration_required?
    legal_form_id && LegalForm.find(legal_form_id).requires_company_registration == true
  end

  def maturity_date_within_loan_term
    loan_term = LoanTerm.new(loan)

    if maturity_date < loan_term.earliest_start_date
      errors.add(:maturity_date, :less_than_min_loan_term)
    end

    if maturity_date > loan_term.latest_end_date
      errors.add(:maturity_date, :greater_than_max_loan_term)
    end
  end

  def save_as_ineligible
    loan.transaction do
      save_as_incomplete
      save_ineligibility_reasons
    end
  end

end
