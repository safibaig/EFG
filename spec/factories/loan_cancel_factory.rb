FactoryGirl.define do
  factory :loan_cancel do
    cancelled_reason CancelReason.find(1)
    cancelled_comment 'No comment'
    cancelled_on '01/06/2012'

    initialize_with {
      loan = FactoryGirl.build(:loan, :eligible)
      new(loan)
    }
  end
end
