FactoryGirl.define do
  factory :user do
    lender
    first_name 'Joe'
    last_name 'Bloggs'
    sequence(:email) { |n| "joe#{n}@example.com" }
    password 'password'
  end
end
