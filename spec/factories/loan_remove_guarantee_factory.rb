FactoryGirl.define do
  factory :loan_remove_guarantee do
    remove_guarantee_on '20/05/2011'
    remove_guarantee_outstanding_amount Money.new(10_000_00)
    remove_guarantee_reason 'N/A'

    initialize_with {
      loan = FactoryGirl.build(:loan, :guaranteed)
      new(loan)
    }
  end
end
