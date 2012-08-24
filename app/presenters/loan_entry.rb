class LoanEntry
  include LoanPresenter
  include LoanStateTransition

  transition from: [Loan::Eligible, Loan::Incomplete], to: Loan::Completed, event: :complete

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
                        :interest_rate, :fees, :repayment_duration

  validate :state_aid_calculated

  validate :repayment_frequency_allowed

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

  validates_presence_of :current_refinanced_value, :final_refinanced_value,
                        if: lambda { loan_category_id == 4 }

  # TYPE E LOANS

  validates_presence_of :overdraft_limit,
                        if: lambda { loan_category_id == 5 }

  validates_inclusion_of :overdraft_maintained,
                         in: [true],
                         if: lambda { loan_category_id == 5 }

  validate :type_e_repayment_duration, if: lambda { loan_category_id == 5 }

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

  validate :type_f_repayment_duration, if: lambda { loan_category_id == 6 }

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

  def repayment_frequency_allowed
    return unless repayment_frequency_id.present? && repayment_duration.present?
    case repayment_frequency_id
    when 1
      errors.add(:repayment_frequency_id, :not_allowed) unless repayment_duration.total_months % 12 == 0
    when 2
      errors.add(:repayment_frequency_id, :not_allowed) unless repayment_duration.total_months % 6 == 0
    when 3
      errors.add(:repayment_frequency_id, :not_allowed) unless repayment_duration.total_months % 3 == 0
    end
  end

  # Type B loans require at least one security
  def loan_security
    errors.add(:loan_security_types, :present) if self.loan_security_types.empty?
  end

  # Type E repayment duration cannot exceed 2 years
  def type_e_repayment_duration
    unless repayment_duration.between?(MonthDuration.new(3), MonthDuration.new(24))
      errors.add(:repayment_duration, :invalid)
    end
  end

  # Type F repayment duration cannot exceed 3 years
  def type_f_repayment_duration
    unless repayment_duration.between?(MonthDuration.new(3), MonthDuration.new(36))
      errors.add(:repayment_duration, :invalid)
    end
  end

end
