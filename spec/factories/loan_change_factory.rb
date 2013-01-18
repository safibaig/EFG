FactoryGirl.define do
  factory :loan_change do
    loan
    created_by factory: :user
    date_of_change '1/2/12'
    change_type_id ChangeType::BusinessName.id
    modified_date '3/4/12'
    business_name 'ACME'

    trait :reschedule do
      state_aid_calculation_attributes { |loan_change|
        FactoryGirl.attributes_for(:rescheduled_state_aid_calculation, loan: loan_change.loan)
      }
    end
  end
end
