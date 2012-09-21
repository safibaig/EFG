FactoryGirl.define do
  factory :user_audit do
    user
    password "349usdf"
    function UserAudit::INITIAL_LOGIN
    association :modified_by, factory: :user
  end
end
