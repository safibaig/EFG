class EligibilityCheck
  def self.eligible?(loan)
    EligibilityCheck.new(loan).eligible?
  end

  def initialize(loan)
    @loan = loan
    @errors = ActiveModel::Errors.new(loan)
  end

  attr_reader :loan, :errors

  def eligible?
    run_checks
    @errors.empty?
  end

  private
  def run_checks
    errors.add(:viable_proposition) unless loan.viable_proposition?
    errors.add(:would_you_lend) unless loan.would_you_lend?
    errors.add(:collateral_exhausted) unless loan.collateral_exhausted?
    errors.add(:amount) unless loan.amount.between?(Money.new(1_000_00), Money.new(1_000_000_00))
    errors.add(:turnover) if loan.turnover > Money.new(5_600_000_00)
    errors.add(:previous_borrowing) unless loan.previous_borrowing?
    errors.add(:private_residence_charge_required) if loan.private_residence_charge_required?
    errors.add(:personal_guarantee_required) if loan.personal_guarantee_required?
    errors.add(:repayment_duration) unless loan.repayment_duration.between?(MonthDuration.new(3), MonthDuration.new(120))
  end
end
