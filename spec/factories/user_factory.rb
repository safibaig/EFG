FactoryGirl.define do
  factory :user do
    lender
    name 'Joe Bloggs'
    sequence(:email) { |n| "joe#{n}@example.com" }
    password 'password'
  end
end
