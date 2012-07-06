class Recovery < ActiveRecord::Base
  belongs_to :loan
  belongs_to :created_by, class_name: 'LenderUser'

  validates_presence_of :loan, :created_by, :recovered_on,
    :total_proceeds_recovered, :total_liabilities_after_demand,
    :total_liabilities_behind, :additional_break_costs,
    :additional_interest_accrued, :amount_due_to_dti, :realise_flag,
    :outstanding_non_efg_debt, :non_linked_security_proceeds,
    :linked_security_proceeds, :realisations_attributable,
    :realisations_due_to_gov
end
