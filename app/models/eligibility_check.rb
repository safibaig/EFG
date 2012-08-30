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
    add_error(:turnover) if loan.turnover > Money.new(5_600_000_00)
    add_error(:previous_borrowing) unless loan.previous_borrowing?
    add_error(:private_residence_charge_required) if loan.private_residence_charge_required?
    add_error(:repayment_duration) unless loan.repayment_duration.between?(MonthDuration.new(3), MonthDuration.new(120))
  end

  def add_error(attribute)
    errors.add(attribute, :invalid, message: I18n.translate("eligibility_check.attributes.#{attribute}.invalid"))
  end
end
