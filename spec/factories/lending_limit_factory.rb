FactoryGirl.define do
  factory :lending_limit do
    lender
    allocation 1000000
    allocation_type_id 1
    description 'Annual'
    starts_on 1.month.ago
    ends_on 11.months.from_now
    premium_rate 2
    guarantee_rate 75
  end
end
