FactoryGirl.define do
  factory :loan_allocation do
    lender
    allocation 1000000
    starts_on 1.month.ago
    ends_on 11.months.from_now
  end
end
