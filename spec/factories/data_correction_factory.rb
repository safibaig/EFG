FactoryGirl.define do
  factory :data_correction do
    loan
    created_by factory: :user
    change_type_id '9'
    date_of_change { Date.current }
    modified_date { Date.current }
    sortcode '666666'
  end
end
