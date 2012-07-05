FactoryGirl.define do
  factory :invoice do
    lender
    association :created_by, factory: :user
    reference '191767-INV'
    period_covered_quarter 'December'
    period_covered_year '2006'
    received_on Date.new(2007, 1, 10)
  end
end
