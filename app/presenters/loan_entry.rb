class LoanEntry
  include LoanPresenter
  include LoanStateTransition

  transition from: [Loan::Eligible, Loan::Incomplete], to: Loan::Completed

  attribute :viable_proposition, read_only: true
  attribute :would_you_lend, read_only: true
  attribute :collateral_exhausted, read_only: true
  attribute :sic_code, read_only: true
  attribute :loan_category_id, read_only: true
  attribute :reason_id, read_only: true
  attribute :previous_borrowing, read_only: true
  attribute :private_residence_charge_required, read_only: true
  attribute :personal_guarantee_required, read_only: true
  attribute :amount, read_only: true
  attribute :turnover, read_only: true
  attribute :trading_date, read_only: true
  attribute :loan_allocation_id, read_only: true
  attribute :lender, read_only: true

  attribute :repayment_duration
  attribute :declaration_signed
  attribute :business_name
  attribute :trading_name
  attribute :legal_form_id
  attribute :maturity_date
  attribute :company_registration
  attribute :postcode
  attribute :non_validated_postcode
  attribute :branch_sortcode
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
  attribute :current_refinanced_value
  attribute :final_refinanced_value
  attribute :overdraft_limit
  attribute :overdraft_maintained
  attribute :invoice_discount_limit
  attribute :debtor_book_coverage
  attribute :debtor_book_topup

  validates_presence_of :business_name, :legal_form_id, :interest_rate_type_id,
                        :repayment_frequency_id, :postcode, :maturity_date,
                        :interest_rate, :fees

  validates_presence_of :security_proportion,
                        if: lambda { loan_category_id == 2 }

  validates_presence_of :original_overdraft_proportion, :refinance_security_proportion,
                        if: lambda { loan_category_id == 3 }

  validates_presence_of :refinance_security_proportion, :current_refinanced_value,
                        :final_refinanced_value,
                        if: lambda { loan_category_id == 4 }

  validates_presence_of :overdraft_limit,
                        if: lambda { loan_category_id == 5 }

  validates_inclusion_of :overdraft_maintained,
                         in: [true],
                         if: lambda { loan_category_id == 5 }

  validates_presence_of :invoice_discount_limit, :debtor_book_coverage,
                        :debtor_book_topup,
                        if: lambda { loan_category_id == 6 }

  validate do
    errors.add(:declaration_signed, :accepted) unless self.declaration_signed
    errors.add(:state_aid, :calculated) unless self.loan.state_aid_calculation
    errors.add(:loan_security_types, :present) if loan_category_id == 2 && self.loan_security_types.empty?

    # Type E repayment duration cannot exceed 2 years
    if loan_category_id == 5 && !repayment_duration.between?(MonthDuration.new(3), MonthDuration.new(24))
      errors.add(:repayment_duration, :invalid)
    end

    # Type F repayment duration cannot exceed 3 years
    if loan_category_id == 6 && !repayment_duration.between?(MonthDuration.new(3), MonthDuration.new(36))
      errors.add(:repayment_duration, :invalid)
    end
  end

  def save_as_incomplete
    loan.state = Loan::Incomplete
    loan.save(validate: false)
  end
end
