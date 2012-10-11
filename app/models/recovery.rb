class Recovery < ActiveRecord::Base
  include FormatterConcern

  belongs_to :loan
  belongs_to :created_by, class_name: 'User'
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

  def calculate
    loan_guarantee_rate = loan.guarantee_rate / 100

    if loan.efg_loan?
      # See Visio document page 34.
      self.realisations_attributable = [
        non_linked_security_proceeds + linked_security_proceeds - outstanding_non_efg_debt,
        Money.new(0)
      ].max

      self.amount_due_to_dti = realisations_attributable * loan_guarantee_rate
    else
      magic_number = if loan.legacy_loan?
        another_magic_number = loan.dti_amount_claimed / loan_guarantee_rate
        another_magic_number / (another_magic_number + total_liabilities_behind)
      else
        interest_plus_outstanding = loan.dti_interest + loan.dti_demand_outstanding
        interest_plus_outstanding / (interest_plus_outstanding + total_liabilities_behind)
      end

      self.realisations_attributable = total_liabilities_after_demand * loan_guarantee_rate * magic_number

      self.amount_due_to_dti = realisations_attributable + additional_break_costs + additional_interest_accrued
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
        modified_by: created_by,
        event_id: 20 # Recovery made
      )
    end
end
