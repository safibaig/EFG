FactoryGirl.define do
  factory :recovery do
    loan
    created_by factory: :lender_user
    recovered_on { Date.today }
    total_proceeds_recovered Money.new(10_000_00)
    total_liabilities_after_demand Money.new(10_000_00)
    total_liabilities_behind Money.new(10_000_00)
    additional_break_costs Money.new(10_000_00)
    additional_interest_accrued Money.new(10_000_00)
    amount_due_to_dti Money.new(10_000_00)
    realise_flag true
    outstanding_non_efg_debt Money.new(10_000_00)
    non_linked_security_proceeds Money.new(10_000_00)
    linked_security_proceeds Money.new(10_000_00)
    realisations_attributable Money.new(10_000_00)
    realisations_due_to_gov Money.new(10_000_00)
  end
end
