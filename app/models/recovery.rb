class Recovery < ActiveRecord::Base
  include FormatterConcern

  belongs_to :loan
  belongs_to :created_by, class_name: 'LenderUser'
  belongs_to :realisation_statement

  scope :realised, where(realise_flag: true)

  validates_presence_of :loan, :created_by, :recovered_on,
    :outstanding_non_efg_debt, :non_linked_security_proceeds,
    :linked_security_proceeds

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
  format :realisations_attributable, with: MoneyFormatter.new
  format :amount_due_to_dti, with: MoneyFormatter.new
  format :total_proceeds_recovered, with: MoneyFormatter.new
  format :total_liabilities_after_demand, with: MoneyFormatter.new
  format :total_liabilities_behind, with: MoneyFormatter.new
  format :additional_break_costs, with: MoneyFormatter.new
  format :additional_interest_accrued, with: MoneyFormatter.new
  format :realisations_due_to_gov, with: MoneyFormatter.new

  attr_accessible :recovered_on, :outstanding_non_efg_debt,
    :non_linked_security_proceeds, :linked_security_proceeds

  # See Visio document page 34.
  def calculate
    a = -outstanding_non_efg_debt + non_linked_security_proceeds
    b = a + linked_security_proceeds

    if b > 0
      self.realisations_attributable = b
      self.amount_due_to_dti = b * (loan.guarantee_rate / 100)
    else
      self.realisations_attributable = 0
      self.amount_due_to_dti = 0
    end
  end

  def save_and_update_loan
    transaction do
      save!
      update_loan!
      log_loan_state_change!
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  private
    def update_loan!
      loan.modified_by = created_by
      loan.recovery_on = recovered_on
      loan.state = Loan::Recovered
      loan.save!
    end

    def log_loan_state_change!
      LoanStateChange.create!(
        loan_id: loan.id,
        state: Loan::Recovered,
        modified_on: Date.today,
        modified_by: loan.modified_by,
        event_id: 20 # Recovery made
      )
    end
end
