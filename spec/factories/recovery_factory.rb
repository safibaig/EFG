FactoryGirl.define do
  factory :recovery do
    created_by factory: :lender_user
    recovered_on { Date.today }
    outstanding_non_efg_debt Money.new(10_000_00)
    non_linked_security_proceeds Money.new(10_000_00)
    linked_security_proceeds Money.new(10_000_00)
    realisations_attributable Money.new(10_000_00)
    realisations_due_to_gov Money.new(10_000_00)

    after(:build) { |recovery|
      recovery.loan ||= FactoryGirl.create(:loan, :settled, settled_on: recovery.recovered_on)
    }
  end
end
