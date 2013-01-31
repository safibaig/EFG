FactoryGirl.define do
  factory :phase do
    name 'Phase 1'
    association :created_by, factory: :cfe_admin
    association :modified_by, factory: :cfe_admin
  end
end
