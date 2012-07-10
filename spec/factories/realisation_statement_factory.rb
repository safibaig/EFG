FactoryGirl.define do
  factory :realisation_statement do
    lender
    association :created_by, factory: :user
    reference 'QMH8GHS-01'
    period_covered_quarter 'March'
    period_covered_year '2008'
    received_on Date.new(2008, 1, 10)
  end
end
