FactoryGirl.define do
  factory :demand_to_borrower do
    loan
    association :created_by, factory: :lender_user
    modified_date { Date.current }
    date_of_demand { Date.current }
    demanded_amount 10_000_00
  end
end
