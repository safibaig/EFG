FactoryGirl.define do
  factory :lending_limit do
    lender
    active true
    allocation 1000000
    allocation_type_id 1
    sequence(:name) { |n| "lending limit #{n}" }
    starts_on 1.month.ago
    ends_on { |lending_limit| lending_limit.starts_on.advance(years: 1) }
    premium_rate 2
    guarantee_rate 75
  end
end
