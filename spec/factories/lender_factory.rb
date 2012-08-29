FactoryGirl.define do
  factory :lender do
    can_use_add_cap false
    high_volume true
    sequence(:name) { |n| "Little Tinkers #{n}" }
    association :created_by, factory: :cfe_admin
    association :modified_by, factory: :cfe_admin
    organisation_reference_code 'LT'
    primary_contact_name 'Bob Flemming'
    primary_contact_phone '0123456789'
    primary_contact_email 'bob@example.com'

    trait :with_loan_allocation do
      after :create do |lender|
        FactoryGirl.create(:loan_allocation, lender: lender)
      end
    end
  end
end
