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

  attr_accessible :recovered_on, :outstanding_non_efg_debt,
    :non_linked_security_proceeds, :linked_security_proceeds

  # See Visio document page 34.
  def calculate
    a = -outstanding_non_efg_debt + non_linked_security_proceeds
    b = a + linked_security_proceeds

    if b > 0
      self.realisations_attributable = b
      self.amount_due_to_dti = b * StateAidCalculation::GUARANTEE_RATE
    else
      self.realisations_attributable = 0
      self.amount_due_to_dti = 0
    end
  end

  def save_and_update_loan
    transaction do
      save!
      update_loan!
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
end
