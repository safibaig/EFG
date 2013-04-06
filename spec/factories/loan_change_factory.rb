FactoryGirl.define do
  factory :loan_change do
    loan
    created_by factory: :lender_user
    date_of_change '1/2/12'
    change_type ChangeType::RecordAgreedDraw
    modified_date '3/4/12'
    amount_drawn Money.new(1_000_00)

    trait :reschedule do
      premium_schedule_attributes { |loan_change|
        FactoryGirl.attributes_for(:rescheduled_premium_schedule, loan: loan_change.loan)
      }
    end
  end
end
