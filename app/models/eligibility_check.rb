class EligibilityCheck

  def initialize(loan)
    @loan = loan
    @errors = ActiveModel::Errors.new(loan)
    run_checks
  end

  attr_reader :loan, :errors

  def eligible?
    errors.empty?
  end

  def reasons
    errors.messages.values.flatten
  end

  private
  def run_checks
    add_error(:viable_proposition) unless loan.viable_proposition?
    add_error(:would_you_lend) unless loan.would_you_lend?
    add_error(:collateral_exhausted) unless loan.collateral_exhausted?
    add_error(:amount) unless loan.amount.between?(Money.new(1_000_00), Money.new(1_000_000_00))
    add_error(:previous_borrowing) unless loan.previous_borrowing?
    add_error(:private_residence_charge_required) if loan.private_residence_charge_required?
    add_error(:sic_code) unless loan.sic_eligible?
    add_error(:trading_date) if loan.trading_date > Date.today.advance(months: 6)
    check_repayment_duration
  end

  def add_error(attribute)
    errors.add(attribute, :invalid, message: I18n.translate("eligibility_check.attributes.#{attribute}.invalid"))
  end

  def check_repayment_duration
    loan_term = LoanTerm.new(loan)
    unless loan.repayment_duration.total_months.between?(loan_term.min_months, loan_term.max_months)
      add_error(:repayment_duration)
    end
  end

end
