FactoryGirl.define do
  factory :lender do
    sequence(:name) { |n| "Little Tinkers #{n}" }
    association :created_by, factory: :cfe_admin
    association :modified_by, factory: :cfe_admin

    after(:create) do |lender|
      FactoryGirl.create(:loan_allocation, lender: lender)
    end
  end
end
