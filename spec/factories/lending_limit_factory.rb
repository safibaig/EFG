FactoryGirl.define do
  factory :lending_limit do
    lender
    phase
    active true
    allocation 1000000
    allocation_type_id LendingLimitType::Annual.id
    sequence(:name) { |n| "lending limit #{n}" }
    starts_on 1.month.ago
    ends_on { |lending_limit| lending_limit.starts_on.advance(years: 1) }
    premium_rate 2
    guarantee_rate 75

    trait :active do
      active true
    end

    trait :inactive do
      active false
    end
  end
end
