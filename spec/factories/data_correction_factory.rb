FactoryGirl.define do
  factory :data_correction do
    loan
    created_by factory: :user
    amount Money.new(10_000_00)
    change_type_id '9'
    date_of_change { Date.current }
    modified_date { Date.current }
  end
end
