FactoryGirl.define do
  factory :admin_audit do
    association :auditable, factory: :cfe_admin
    association :modified_by, factory: :cfe_admin
    action 'User unlocked'
    modified_on { Date.current }
  end
end
