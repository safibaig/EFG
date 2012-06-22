FactoryGirl.define do
  factory :lender do
    name 'Little Tinkers'
    after(:create) do |lender|
      FactoryGirl.create(:loan_allocation, lender: lender)
    end
  end
end
