FactoryGirl.define do
  factory :user do
    first_name 'Joe'
    last_name 'Bloggs'
    sequence(:email) { |n| "joe#{n}@example.com" }
    password 'password'

    factory :cfe_user, class: CfeUser

    factory :lender_user, class: LenderUser do
      lender
    end

    factory :premium_collector_user, class: PremiumCollectorUser
  end
end
