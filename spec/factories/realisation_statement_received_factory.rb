FactoryGirl.define do
  factory :realisation_statement_received do
    lender
    association :creator, factory: :user
    reference '87128973-KLS'
    period_covered_quarter 'December'
    period_covered_year '2006'
    received_on Date.new(2007, 1, 10)

    recoveries_to_be_realised_ids { |realisation_statement|
      loan = FactoryGirl.create(:loan, :recovered,
        lender: realisation_statement.lender,
        settled_on: Date.new(2008)
      )
      recovery = FactoryGirl.create(:recovery, loan: loan)
      [recovery.id]
    }

    initialize_with {
      new
    }
  end
end