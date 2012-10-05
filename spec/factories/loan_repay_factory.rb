FactoryGirl.define do
  factory :loan_repay do
    repaid_on 1.day.from_now.to_date

    initialize_with {
      loan = FactoryGirl.create(:loan, :guaranteed)
      new(loan)
    }
  end
end
