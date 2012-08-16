FactoryGirl.define do
  factory :lender do
    sequence(:name) { |n| "Little Tinkers #{n}" }
    after(:create) do |lender|
      FactoryGirl.create(:loan_allocation, lender: lender)
    end
  end
end
