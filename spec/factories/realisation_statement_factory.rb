FactoryGirl.define do
  factory :realisation_statement do
    lender
    association :created_by, factory: :user
    reference 'QMH8GHS-01'
    period_covered_quarter 'March'
    period_covered_year '2008'
    received_on Date.new(2008, 1, 10)
    recoveries_to_be_realised_ids { |realisation_statement|
      loan = FactoryGirl.create(:loan, :recovered,
        lender: realisation_statement.lender,
        settled_on: Date.new(2008)
      )
      recovery = FactoryGirl.create(:recovery, loan: loan)
      [recovery.id]
    }
  end
end
