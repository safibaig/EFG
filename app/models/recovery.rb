class Recovery < ActiveRecord::Base
  include FormatterConcern

  VALID_LOAN_STATES = [Loan::Settled, Loan::Recovered]

  belongs_to :loan
  belongs_to :created_by, class_name: 'LenderUser'

  validates_presence_of :loan, :created_by, :recovered_on,
    :outstanding_non_efg_debt, :non_linked_security_proceeds,
    :linked_security_proceeds, strict: true

  validate do
    return unless recovered_on && loan

    if recovered_on < loan.settled_on
      errors.add(:recovered_on, 'must not be before the loan was settled')
    end
  end

  format :recovered_on, with: QuickDateFormatter
  format :outstanding_non_efg_debt, with: MoneyFormatter.new
  format :non_linked_security_proceeds, with: MoneyFormatter.new
  format :linked_security_proceeds, with: MoneyFormatter.new

  attr_accessible :recovered_on, :outstanding_non_efg_debt,
    :non_linked_security_proceeds, :linked_security_proceeds

  def update_loan!
    loan.recovery_on = recovered_on
    loan.state = Loan::Recovered
    loan.save!
  end
end
