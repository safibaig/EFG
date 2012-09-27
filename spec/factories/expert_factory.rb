FactoryGirl.define do
  factory :expert do
    association :user, factory: :lender_admin
  end
end
