FactoryGirl.define do
  factory :loan_cancel do
    cancelled_reason_id 1
    cancelled_comment 'No comment'
    cancelled_on Date.today

    initialize_with {
      loan = FactoryGirl.build(:loan, :eligible)
      new(loan)
    }
  end
end
