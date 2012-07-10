class RecoveryPresenter
  extend  ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::MassAssignmentSecurity

  class IncorrectLoanState < StandardError; end

  attr_reader :loan, :recovery

  RECOVERY_ATTRIBUTES = %w(recovered_on)

  RECOVERY_ATTRIBUTES.each do |name|
    delegate name, "#{name}=", to: :recovery
    attr_accessible name
  end

  delegate :created_by, :created_by=, to: :recovery
  delegate :persisted?, to: :recovery

  def initialize(loan)
    @loan = loan
    @recovery = loan.recoveries.new
    raise IncorrectLoanState unless [Loan::Settled, Loan::Recovered].include?(loan.state)
  end

  def attributes=(attr)
    sanitize_for_mass_assignment(attr).each do |k, v|
      public_send("#{k}=", v)
    end
  end

  def save
    return false unless recovery.valid?

    recovery.transaction do
      recovery.save!

      loan.recovery_on = recovered_on
      loan.state = Loan::Recovered
      loan.save!
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  def to_model
    recovery
  end
end
