FactoryGirl.define do
  factory :invoice_received do
    lender
    association :creator, factory: :user
    reference '191767-IN V'
    period_covered_quarter 'December'
    period_covered_year '2006'
    received_on Date.new(2007, 1, 10)

    initialize_with {
      new
    }
  end
end