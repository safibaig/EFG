FactoryGirl.define do
  factory :bulk_lending_limits do
    phase_id 23
    sequence(:lending_limit_name) { |n| "lending limit #{n}" }
    allocation_type_id 1
    starts_on 1.month.ago
    ends_on { |lending_limit| lending_limit.starts_on.advance(years: 1) }
    premium_rate 2
    guarantee_rate 75

    association :created_by, factory: :cfe_admin
    association :modified_by, factory: :cfe_admin
  end
end
