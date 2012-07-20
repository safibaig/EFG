FactoryGirl.define do
  factory :loan_change do
    loan
    created_by factory: :user
    date_of_change '1/2/12'
    change_type_id '1'
    modified_date '3/4/12'
  end
end
